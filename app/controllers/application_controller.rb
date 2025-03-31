class ApplicationController < ActionController::Base
  impersonates :user
  include Pundit::Authorization
  include TurboStreamHelper

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit
  before_action :set_sentry_context
  before_action :build_user_alerts
  before_action :redirect_to_security_charter

  after_action :verify_authorized, unless: :skip_pundit?
  after_action :track_action
  around_action :set_time_zone

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      'authentication'
    elsif params[:controller] == 'errors'
      'application'
    elsif %w[unsubscribe public_pages].include?(params[:controller])
      'public_pages'
    else
      'agent_interface'
    end
  end

  def set_time_zone
    if user_signed_in?
      Time.use_zone(current_time_zone) { yield }
    else
      yield
    end
  end

  def after_sign_in_path_for(_)
    stored_location_for(current_user) || root_path
  end

  def after_sign_out_path_for(_)
    new_user_session_path
  end

  def current_organization
    @current_organization ||= current_user&.organization
  end
  helper_method :current_organization

  def current_time_zone
    @current_time_zone ||= TZInfo::Timezone.get(current_organization.time_zone)
  end
  helper_method :current_time_zone

  def user_for_paper_trail
    true_user.try(:id)
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def skip_pundit?
    devise_controller? || %w[public_pages].include?(params[:controller])
  end

  def track_action
    ahoy.track 'Ran action', request.query_parameters.merge(request.path_parameters)
  end

  def user_not_authorized
    respond_to do |format|
      format.html do
        flash[:alert] = I18n.t('errors.non_authorized')
        redirect_to(request.referrer || root_path)
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('turbostream_error_messages', partial: 'shared/unauthorized_error')
      end
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: %i[first_name last_name role email organization_id phone])
  end

  def set_sentry_context
    Sentry.set_user(email: current_user.email) if user_signed_in?
  end

  def build_user_alerts
    return unless user_signed_in?

    @unread_alerts = UserAlert.unread_by(current_user)
  end

  def redirect_to_security_charter
    return unless user_signed_in? &&
                  !current_user.security_charter_accepted? &&
                  controller_name != 'security_charter_acceptances' &&
                  !(controller_name == 'sessions' && action_name == 'destroy') &&
                  action_name != 'stop_impersonating'

    redirect_to new_security_charter_acceptance_path
  end
end
