class AppiImportJob < ApplicationJob
  require 'csv'
  require 'digest/bubblebabble'
  queue_as :default

  def perform(appi_data, organization, user, csv_errors, other_organizations)
    @import_errors = []
    @import_successes = []

    process_appi_data(appi_data, organization, other_organizations)
  rescue StandardError => e
    @import_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user: user, organization: organization, import_errors: @import_errors,
                     import_successes: @import_successes, csv_errors: csv_errors).appi_import_report.deliver_later
  end

  def process_appi_data(appi_data, organization, other_organizations = [])
    appi_data.each do |c|
      create_convict(c, organization, other_organizations)
    end
  end

  def create_convict(convict, organization, other_organizations)
    convict = Convict.new(
      first_name: convict[:first_name],
      last_name: staging? ? anonymize(convict) : convict[:last_name],
      date_of_birth: convict[:date_of_birth].present? ? convict[:date_of_birth].to_date : nil,
      no_phone: true,
      appi_uuid: convict[:appi_uuid]
    )

    convict.organizations.push(organization) unless convict.organizations.include?(organization)

    organization.linked_organizations.each do |linked_organization|
      convict.organizations.push(linked_organization) unless convict.organizations.include?(linked_organization)
    end

    other_organizations.each do |orga|
      convict.organizations.push(orga) unless convict.organizations.include?(orga)
    end

    if convict.save && convict.valid?(:appi_impport)
      @import_successes.push("#{convict.first_name} #{convict.last_name} (id: #{convict.id})")
    else
      @import_errors.push("#{convict.first_name} #{convict.last_name} - #{convict.errors.full_messages.first}")
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
