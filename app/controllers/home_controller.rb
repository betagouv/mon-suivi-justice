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

    if @stats[:passed_uninformed_percentage] > 20
      flash[:alert] = I18n.t('home.notice.fill_out_appointments', @stats[:passed_uninformed_percentage])
    end


  end
end
