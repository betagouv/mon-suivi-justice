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
      sign_out(true_user)
      ActiveRecord::Base.connection.tables.each do |t|
        # We don't want to delete the SRJ tables
        next if ['cities', 'tjs', 'spips', 'commune', 'structure', 'type_structure', 'ln_commune_structure'].include?(t)
        conn = ActiveRecord::Base.connection
        conn.execute("TRUNCATE TABLE #{t} CASCADE;")
        conn.reset_pk_sequence!(t)
      end
      Rails.application.load_seed
      @admin = User.find_by email: 'admin@example.com'
      sign_in(@admin)
      redirect_to admin_root_path
    end

    private

    def show_search_bar?
      false
    end
  end
end
