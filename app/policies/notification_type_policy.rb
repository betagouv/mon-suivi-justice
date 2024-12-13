class NotificationTypePolicy < ApplicationPolicy
  def update?
    return false unless user.security_charter_accepted?
    return false if record.is_default? || record.still_default?

    user.admin?
  end
end
