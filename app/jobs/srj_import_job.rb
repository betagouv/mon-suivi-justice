class SrjImportJob < ApplicationJob
  require 'csv'
  queue_as :default

  def perform(srj_data, user, csv_errors)
    @import_errors = []
    @import_successes = []

    process_srj_data(srj_data)
  rescue StandardError => e
    @import_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user: user, import_errors: @import_errors,
                     import_successes: @import_successes, csv_errors: csv_errors).srj_import_report.deliver_later
  end

  def process_srj_data(srj_data)
    srj_data.each do |row|
      city_attributes = {
        name: row['names'],
        code_insee: row['insee_code'],
        zipcode: row['postal_code']
      }

      city = City.new(city_attributes)
      if city.save
        @import_success << "City '#{city.name}' successfully saved."
        associate_srj(row['type'], row['service_name'], city)
      else
        @import_errors << "Error saving city '#{city.name}': #{city.errors.full_messages.join(', ')}"
      end
    end
  end

  private

  def associate_srj(type, srj_name, city)
    if type == 'SPIP' || type == 'ALIP'
      srj_spip = SrjSpip.find_or_create_by(name: srj_name)
      city.update(srj_spip: srj_spip)
      @import_success << "SrjSpip '#{srj_spip.name}' associated with city '#{city.name}'."
    elsif type == 'TJ'
      srj_tj = SrjTj.find_or_create_by(name: srj_name)
      city.update(srj_tj: srj_tj)
      @import_success << "SrjTj '#{srj_tj.name}' associated with city '#{city.name}'."
    end
  end
end
