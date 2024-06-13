module Admin
  class ImportConvictsController < Admin::ApplicationController
    include Devise::Controllers::Helpers

    def index
      render locals: {
        resources: [],
        search_term: '',
        page: '',
        show_search_bar: show_search_bar?
      }
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def import
      @file_extension = File.extname(params[:convicts_list].original_filename)
      raise StandardError, 'Seul le format csv est supporté' unless %w[.csv].include? @file_extension.downcase

      if params[:organization_id].blank?
        raise StandardError,
              'Veuillez selectionner au moins 1 organization'
      end

      @organization = Organization.find(params[:organization_id]) if params[:organization_id].present?

      temp_csv = params[:convicts_list].tempfile
      # rubocop:disable Style/RedundantDoubleSplatHashBraces
      csv = CSV.read(temp_csv,
                     **{ headers: true, col_sep: ';', external_encoding: 'iso-8859-1', internal_encoding: 'utf-8' })
      # rubocop:enable Style/RedundantDoubleSplatHashBraces

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
      flash[:error] = "Erreur : #{e.message}"
    else
      target = [@organization] if @organization.present?

      AppiImportJob.perform_later(appi_data, target, current_user, csv_errors) if target.present?
      flash[:success] =
        'Import en cours ! Vous recevrez le rapport par mail dans quelques minutes'
    ensure
      temp_csv&.unlink
      redirect_to admin_import_convicts_path
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    private

    def show_search_bar?
      false
    end
  end
end
