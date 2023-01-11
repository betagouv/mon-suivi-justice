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

      temp_csv = params[:convicts_list].tempfile
      csv = CSV.read(temp_csv, {headers: true, col_sep: ";", external_encoding: 'iso-8859-1', internal_encoding: "utf-8"})

      csv.each do |row|
        puts row.to_hash
      end

    rescue StandardError => e
      flash[:error] = "Erreur : #{e.message}"
    else
      flash[:success] =
        'Les ppsmjs ont correctements été importées'
    ensure
      redirect_to admin_import_convicts_path
      temp_csv.unlink
    end

    private

    def show_search_bar?
      false
    end
  end
end
