class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, unless: :devise_controller?

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      "authentication"
    else
      "agent_interface"
    end
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = I18n.t('errors.non_authorized')
    redirect_to(request.referrer || root_path)
  end
end
