class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def home
    @convicts = policy_scope(Convict.all)

    data = DataCollector.perform

    @convicts_count = data[:convicts]
    @users = data[:users]
    @notifications = data[:notifications]

    @recorded = data[:recorded]
    @fulfiled = data[:fulfiled]
    @no_show = data[:no_show]
    @excused = data[:excused]
    @canceled = data[:canceled]

    @future_booked = data[:future_booked]
    @passed_booked = data[:passed_booked]
    @passed_no_canceled = data[:passed_no_canceled]
  end
end
