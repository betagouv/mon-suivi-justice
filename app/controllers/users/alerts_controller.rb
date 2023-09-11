module Users
  class AlertsController < ApplicationController
    def index
      @user_alerts = policy_scope([:users, UserAlert])
      authorize @user_alerts
    end
  end
end
