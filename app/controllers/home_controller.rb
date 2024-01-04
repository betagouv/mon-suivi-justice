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
    return if current_user.work_at_bex?

    if (%w[cpip dpip].include? current_user.role) && current_user.too_many_appointments_without_status?
      message = I18n.t('home.notice.fill_out_appointments_cpip')
      link = view_context.link_to I18n.t('home.notice.click_here'), appointments_path(waiting_line: true)
      flash.now[:warning] = "#{message}&nbsp#{link}".html_safe

    elsif (%w[cpip dpip].exclude? current_user.role) && current_organization.too_many_appointments_without_status?
      message = I18n.t('home.notice.fill_out_appointments')
      link = view_context.link_to I18n.t('home.notice.click_here'), appointments_path(waiting_line: true)
      flash.now[:warning] = "#{message}&nbsp#{link}".html_safe
    end
  end
end
