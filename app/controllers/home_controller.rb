class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def home
    display_uninformed_appointments
  end

  private

  def display_uninformed_appointments
    return if current_user.work_at_bex?

    if %w[cpip dpip].include?(current_user.role)
      flash_warning('cpip') if current_user.too_many_appointments_without_status?
    elsif %w[cpip dpip].exclude?(current_user.role) && current_organization.too_many_appointments_without_status?
      flash_warning('default')
    end
  end

  def flash_warning(type)
    key_suffix = type == 'cpip' ? 'fill_out_appointments_cpip' : 'fill_out_appointments'
    message = I18n.t("home.notice.#{key_suffix}")
    link = view_context.link_to I18n.t('home.notice.click_here'), appointments_path(waiting_line: true)
    flash.now[:warning] = "#{message}&nbsp#{link}".html_safe
  end
end
