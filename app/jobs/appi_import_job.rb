class AppiImportJob < ApplicationJob
  require 'csv'
  require 'digest/bubblebabble'
  queue_as :default

  def perform(appi_data, organizations, user, csv_errors)
    @import_errors = []
    @import_successes = []

    process_appi_data(appi_data, organizations)
  rescue StandardError => e
    @import_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user:, organizations:, import_errors: @import_errors,
                     import_successes: @import_successes, csv_errors:,
                     import_update_successes: @import_update_successes,
                     import_update_failures: @import_update_failures,
                     target_organizations_names: @target_organizations_names
                    ).appi_import_report.deliver_later
  end

  def process_appi_data(appi_data, organizations)
    appi_data.each do |c|
      create_convict(c, organizations)
    end
  end

  def create_convict(convict, organizations)
    existing_convict = Convict.find_by(appi_uuid: convict[:appi_uuid])

    @import_update_successes = []
    @import_update_failures = []

    if existing_convict
      if existing_convict.organizations.count == 1
        existing_organization = existing_convict.organizations.first

        organizations.each do |org|
          if org.linked_organizations.include?(existing_organization) && existing_organization.organization_type != org.organization_type
            existing_convict.organizations << org
          end
        end

        if existing_convict.save
          @import_update_successes.push("#{existing_convict.first_name} #{existing_convict.last_name} (id: #{existing_convict.id})")
        else
          @import_update_failures.push("#{existing_convict.first_name} #{existing_convict.last_name} - #{existing_convict.errors.full_messages.first}")
        end
      end

    else

      convict = Convict.new(
        first_name: convict[:first_name],
        last_name: staging? ? anonymize(convict) : convict[:last_name],
        date_of_birth: convict[:date_of_birth].present? ? convict[:date_of_birth].to_date : nil,
        no_phone: true,
        appi_uuid: convict[:appi_uuid]
      )

      convict.organization_ids = organizations.map do |org|
        linked_org_ids = org.linked_organizations.map(&:id)
        linked_org_ids.size >= 2 ? org.id : [org.id, linked_org_ids].flatten
      end.flatten.uniq

      @target_organizations_names = Organization.where(id: convict.organization_ids).pluck(:name)

      if convict.save(context: :appi_import)
        @import_successes.push("#{convict.first_name} #{convict.last_name} (id: #{convict.id})")
      else
        @import_errors.push("#{convict.first_name} #{convict.last_name} - #{convict.errors.full_messages.first}")
      end

    end
  end

  private

  def staging?
    ENV['APP'] == 'mon-suivi-justice-staging'
  end

  def anonymize(convict)
    Digest::SHA256.bubblebabble convict[:last_name]
  end
end
