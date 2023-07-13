module Admin
  class ImportSrjsController < Admin::ApplicationController
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

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def import
      temp_csv = params[:srj_file].tempfile
      csv = CSV.read(temp_csv,
                     { headers: true, col_sep: ',' })

      @import_errors = []
      @import_successes = []
      csv_errors = []
      srj_data = []

      csv.each_with_index do |row, i|
        srj_row = {
          name: row['names'],
          code_insee: row['insee_code'],
          zipcode: row['postal_code'],
          service_name: row['name'],
          type: row['type']
        }

        srj_data.push(srj_row)
      rescue StandardError => e
        csv_errors.push("Erreur : #{e.message} sur la ligne #{i}")
      end
    rescue StandardError => e
      flash.now[:error] = "Erreur : #{e.message}"
    else
      SrjImportJob.perform_later(srj_data, current_user, csv_errors)

      flash.now[:success] =
        'Import SRJ en cours ! Vous recevrez le rapport par mail dans quelques minutes'
    ensure
      temp_csv&.unlink
      render :index
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    def show_search_bar?
      false
    end
  end
end
