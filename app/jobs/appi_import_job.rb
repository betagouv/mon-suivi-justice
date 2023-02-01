class AppiImportJob < ApplicationJob
  require 'csv'
  queue_as :default

  def perform(temp_csv_path, organization, user)
    @import_errors = []
    @import_successes = []

    process_csv(temp_csv_path, organization)
  rescue StandardError => e
    @import_errors.push("Erreur : #{e.message}")
  ensure
    FileUtils.rm_f(temp_csv_path)
    AdminMailer.with(user: user, organization: organization, import_errors: @import_errors,
                     import_successes: @import_successes).appi_import_report.deliver_later
  end

  def process_csv(temp_csv_path, _organization)
    csv = CSV.read(temp_csv_path, { headers: true, col_sep: ';' })
    csv.each do |row|
      next if ['EMPRISONNEMENT', 'AMÉNAGEMENT DE PEINE',
               'Placement en détention provisoire'].include?(row['Mesure/Intervention'].split(' (')[0])

      create_convict(row)
    end
  end

  def create_convict(row)
    convict = Convict.new(
      first_name: row['Prénom'],
      last_name: row['Nom'],
      date_of_birth: row['Date de naissance'].to_date,
      no_phone: true,
      appi_uuid: row['Numéro de dossier'].split('°')[1]
    )

    if convict.save
      RegisterLegalAreas.for_convict convict, from: organization
      @import_successes.push("#{convict.first_name} #{convict.last_name} (id: #{convict.id})")
    else
      @import_errors.push("#{convict.first_name} #{convict.last_name} - #{convict.errors.full_messages.first}")
    end
  end
end
