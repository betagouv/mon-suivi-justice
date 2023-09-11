module Users
  class UserAlertPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        user&.user_alerts&.unread
      end
    end

    def index?
      true
    end
  end
end
