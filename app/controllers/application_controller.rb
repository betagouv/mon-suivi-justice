class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit

  after_action :verify_authorized, unless: :skip_pundit?

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      'authentication'
    elsif %w[stats errors].include?(params[:controller])
      'application'
    else
      'agent_interface'
    end
  end

  def after_sign_in_path_for(_)
    stored_location_for(current_user) || root_path
  end

  def after_sign_out_path_for(_)
    ENV.fetch('PUBLIC_SITE_ROOT', nil)
  end

  def current_organization
    @current_organization ||= current_user&.organization
  end
  helper_method :current_organization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def skip_pundit?
    devise_controller?
  end

  def user_not_authorized
    flash[:alert] = I18n.t('errors.non_authorized')
    redirect_to(request.referrer || root_path)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: %i[first_name last_name role email organization_id phone])
  end
end
