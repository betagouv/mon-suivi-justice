module Admin
  class ImportConvictsController < Admin::ApplicationController
    include Devise::Controllers::Helpers
    require 'csv'

    def index
      render locals: {
        resources: [],
        search_term: '',
        page: '',
        show_search_bar: show_search_bar?
      }
    end

    def import
      @file_extension = File.extname(params[:convicts_list].original_filename)
      raise StandardError, 'Seul le format csv est supporté' unless %w[.csv].include? @file_extension.downcase

      @organization = Organization.find(params[:organization_id])

      temp_csv = params[:convicts_list].tempfile
      csv = CSV.read(temp_csv,
                     { headers: true, col_sep: ';', external_encoding: 'iso-8859-1', internal_encoding: 'utf-8' })

      @import_errors = []
      @import_successes = []
      csv_errors = []
      appi_data = []

      csv.each_with_index do |row, i|
        next if ['EMPRISONNEMENT', 'AMÉNAGEMENT DE PEINE',
                 'Placement en détention provisoire'].include?(row['Mesure/Intervention'].split(' (')[0])

        convict = {
          first_name: row['Prénom'],
          last_name: row['Nom'],
          date_of_birth: row['Date de naissance'].to_date,
          no_phone: true,
          appi_uuid: row['Numéro de dossier'].split('°')[1]
        }

        appi_data.push(convict)
      rescue StandardError => e
        csv_errors.push("Erreur : #{e.message} sur la ligne #{i}")
      end
    rescue StandardError => e
      flash.now[:error] = "Erreur : #{e.message}"
    else
      AppiImportJob.perform_later(appi_data, @organization, current_user, csv_errors)
      flash.now[:success] =
        'Import en cours ! Vous recevrez le rapport par mail dans quelques minutes'
    ensure
      temp_csv.unlink
      render :index
    end

    private

    def show_search_bar?
      false
    end
  end
end
