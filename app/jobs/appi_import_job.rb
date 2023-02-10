class AppiImportJob < ApplicationJob
  require 'csv'
  queue_as :default

  def perform(appi_data, organization, user)
    @import_errors = []
    @import_successes = []

    process_appi_data(appi_data, organization)
  rescue StandardError => e
    @import_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user: user, organization: organization, import_errors: @import_errors,
                     import_successes: @import_successes).appi_import_report.deliver_later
  end

  def process_appi_data(appi_data, organization)
    appi_data.each do |c|
      create_convict(c, organization)
    end
  end

  def create_convict(convict, organization)
    convict = Convict.new(
      first_name: convict[:first_name],
      last_name: convict[:last_name],
      date_of_birth: convict[:date_of_birth].to_date,
      no_phone: true,
      appi_uuid: convict[:appi_uuid].split('°')[1]
    )

    if convict.save
      RegisterLegalAreas.for_convict convict, from: organization
      @import_successes.push("#{convict.first_name} #{convict.last_name} (id: #{convict.id})")
    else
      @import_errors.push("#{convict.first_name} #{convict.last_name} - #{convict.errors.full_messages.first}")
    end
  end
end
