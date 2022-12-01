module Users
  class NotificationsController < ApplicationController
    def index
      @user_notifications = policy_scope([:users, UserNotification])
      authorize @user_notifications
    end

    private
  end
end
