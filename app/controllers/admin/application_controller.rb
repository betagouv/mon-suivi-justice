# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.

module Admin
  class ApplicationController < Administrate::ApplicationController
    impersonates :user
    before_action :authenticate_admin
    after_action :track_action

    def authenticate_admin
      redirect_to root_path unless current_user.admin?
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    private

    def track_action
      ahoy.track 'Ran action', request.query_parameters.merge(request.path_parameters)
    end
  end
end
