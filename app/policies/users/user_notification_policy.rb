module Users
  class UserNotificationPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        user.user_notifications.unread
      end
    end
    def index?
      true
    end
  end
end
