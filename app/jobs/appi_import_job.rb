class AppiImportJob < ApplicationJob
  require 'csv'
  require 'digest/bubblebabble'
  queue_as :default

  def perform(appi_data, target_organizations, user, csv_errors)
    @import_errors = []
    @import_successes = []
    @import_update_successes = Hash.new { |hash, key| hash[key] = [] }
    @import_update_failures = Hash.new { |hash, key| hash[key] = [] }
    @calculated_organizations_names = []

    process_appi_data(appi_data, target_organizations)
  rescue StandardError => e
    @import_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user:, target_organizations:, import_errors: @import_errors,
                     import_successes: @import_successes, csv_errors:,
                     import_update_successes: @import_update_successes,
                     import_update_failures: @import_update_failures,
                     calculated_organizations_names: @calculated_organizations_names.uniq)
               .appi_import_report.deliver_later
  end

  def process_appi_data(appi_data, target_organizations)
    appi_data.each do |c|
      process_convict(c, target_organizations)
    end
  end

  def process_convict(convict, target_organizations)
    existing_convict = Convict.find_by(appi_uuid: convict[:appi_uuid])

    return create_convict(convict, target_organizations) if existing_convict.blank?

    update_convict(existing_convict, target_organizations) if existing_convict.organizations.count == 1
  end

  private

  # rubocop:disable Layout/LineLength
  def update_convict(existing_convict, target_organizations)
    existing_organization = existing_convict.organizations.first

    target_organizations.each do |org|
      if org.linked_organizations.include?(existing_organization) && existing_organization.organization_type != org.organization_type
        existing_convict.organizations << org
      end
    end

    if existing_convict.save
      success_message = "#{existing_convict.first_name} #{existing_convict.last_name} (id: #{existing_convict.id})"
      target_organizations.each do |org|
        @import_update_successes[org.name] << success_message
      end
    else
      failure_message = "#{existing_convict.first_name} #{existing_convict.last_name} - #{existing_convict.errors.full_messages.first}"
      target_organizations.each do |org|
        @import_update_failures[org.name] << failure_message
      end
    end
  end
  # rubocop:enable Layout/LineLength

  def create_convict(convict, organizations)
    convict = Convict.new(
      first_name: convict[:first_name],
      last_name: staging? ? anonymize(convict) : convict[:last_name],
      date_of_birth: convict[:date_of_birth].present? ? convict[:date_of_birth].to_date : nil,
      no_phone: true,
      appi_uuid: convict[:appi_uuid]
    )

    assign_organizations_to_convict(convict, organizations)

    if convict.save(context: :appi_import)
      @import_successes << "#{convict[:first_name]} #{convict[:last_name]} (id: #{convict[:id]})"
    else
      @import_errors << "#{convict[:first_name]} #{convict[:last_name]} - #{convict[:errors][:full_messages][0]}"
    end
  end

  def assign_organizations_to_convict(convict, organizations)
    convict.organization_ids = organizations.flat_map do |org|
      linked_org_ids = org.linked_organizations.ids
      linked_org_ids.size >= 2 ? org.id : [org.id, *linked_org_ids]
    end.uniq

    @calculated_organizations_names.concat(Organization.where(id: convict.organization_ids).pluck(:name))
  end

  def staging?
    ENV['APP'] == 'mon-suivi-justice-staging'
  end

  def anonymize(convict)
    Digest::SHA256.bubblebabble convict[:last_name]
  end
end
