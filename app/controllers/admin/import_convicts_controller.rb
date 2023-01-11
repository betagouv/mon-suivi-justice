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

    def import
      @file_extension = File.extname(params[:convicts_list].original_filename)
      raise StandardError, 'Seul le format csv est supporté' unless %w[.csv].include? @file_extension.downcase
    rescue StandardError => e
      flash[:error] = "Erreur : #{e.message}"
    else
      flash[:success] =
        'Les ppsmjs ont correctements été importées'
    ensure
      redirect_to admin_import_convicts_path
    end

    private

    def show_search_bar?
      false
    end
  end
end
