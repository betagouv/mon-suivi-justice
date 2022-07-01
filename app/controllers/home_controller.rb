class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def home
    @convicts = policy_scope(Convict.all)
    if params[:global_stats]
      @stats = DataCollector.new.perform
      @global_stats = true
    else
      @stats = DataCollector.new(organization_id: current_organization.id).perform
    end

    return unless (@stats[:passed_uninformed_percentage] >= 20 && !current_user.work_at_bex?)

    message = I18n.t('home.notice.fill_out_appointments',
                     data: @stats[:passed_uninformed_percentage])
    link = view_context.link_to 'Cliquez-ici',
                                appointments_path({ q: { state_eq: 'booked', slot_date_lt: Date.today.to_s } })
    flash.now[:alert] = "#{message}&nbsp#{link}".html_safe
  end
end
