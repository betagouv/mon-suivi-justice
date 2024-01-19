class UserNotificationPolicy < ApplicationPolicy
  def index?
    user.security_charter_accepted?
  end
end
