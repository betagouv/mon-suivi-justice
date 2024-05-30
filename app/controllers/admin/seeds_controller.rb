module Admin
  class SeedsController < Admin::ApplicationController
    include Devise::Controllers::Helpers

    def index
      render locals: {
        resources: [],
        search_term: '',
        page: '',
        show_search_bar: show_search_bar?
      }
    end

    def reset_db
      return redirect_to admin_root_path unless Rails.env.development?

      login_email = true_user.email
      sign_out(true_user)
      sign_out(current_user)

      DbResetService.reset_database

      Rails.application.load_seed
      @admin = User.find_by(email: login_email)
      sign_in(@admin)
      redirect_to admin_root_path
    end

    private

    def show_search_bar?
      false
    end
  end
end
