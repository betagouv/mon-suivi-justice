module Users
  class UserNotificationPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        user.user_notifications.newest_first
      end
    end

    def index?
      true
    end
  end
end
