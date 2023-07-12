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
        name: row[:name],
        code_insee: row[:code_insee],
        zipcode: row[:zipcode]
      }

      city = City.find_or_create_by(city_attributes)
      @import_successes << "City '#{city.name}' successfully saved."
      associate_srj(row[:type], row[:service_name], city)
    end
  end

  private

  def associate_srj(type, srj_name, city)
    if %w[SPIP ALIP].include?(type)
      srj_spip = SrjSpip.find_or_create_by(name: srj_name)
      city.update(srj_spip: srj_spip)
      @import_successes << "SrjSpip '#{srj_spip.name}' associated with city '#{city.name}'."
    elsif type == 'TJ'
      srj_tj = SrjTj.find_or_create_by(name: srj_name)
      city.update(srj_tj: srj_tj)
      @import_successes << "SrjTj '#{srj_tj.name}' associated with city '#{city.name}'."
    end
  end
end
