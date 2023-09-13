module Admin
    class UserAlertsController < Admin::ApplicationController  
      def index
        render locals: {
          resources: [],
          search_term: '',
          page: '',
          show_search_bar: show_search_bar?
        }
      end
  
      private
  
      def show_search_bar?
        false
      end
    end
  end
  