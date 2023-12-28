class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def home
    if params[:global_stats]
      @stats = DataCollector::User.new(full_stats: false).perform
      @global_stats = true
    else
      @stats = DataCollector::User.new(organization_id: current_organization.id, full_stats: false).perform
    end

    display_uninformed_appointments
  end

  private

  def display_uninformed_appointments
    return unless @stats[:passed_uninformed_percentage] >= 20 && !current_user.work_at_bex?

    message = setup_flash_message
    link = view_context.link_to I18n.t('home.notice.click_here'), appointments_path(waiting_line: true)
    flash.now[:warning] = "#{message}&nbsp#{link}".html_safe
  end

  def setup_flash_message
    if %w[cpip dpip].include?(current_user.role)
      I18n.t('home.notice.fill_out_appointments_cpip', data: @stats[:passed_uninformed_percentage])
    else
      I18n.t('home.notice.fill_out_appointments', data: @stats[:passed_uninformed_percentage])
    end
  end
end
