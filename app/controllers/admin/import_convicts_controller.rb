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

      #temp_csv = params[:convicts_list].tempfile


      File.open("tmp/import-#{@organization.name}-#{Time.now.to_i}.csv", "w") do |f|     
        f.write(CSV.read(params[:convicts_list], { headers: true, external_encoding: 'iso-8859-1', internal_encoding: 'utf-8' }))
        AppiImportJob.perform_later(f.path, @organization, current_user)
      end

      # Get path to csv 
      #temp_csv_path = temp_csv.path


    rescue StandardError => e
      flash.now[:error] = "Erreur : #{e.message}"
    else
      flash.now[:success] =
        "Import en cours ! Vous recevrez le rapport par mail dans quelques minutes"
    ensure
      render :index
      #temp_csv.unlink
    end

    private

    def import_params
      params.permit(:convicts_list, :organization_id)
    end

    def show_search_bar?
      false
    end
  end
end
