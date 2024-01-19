class UserUserAlertPolicy < ApplicationPolicy
  def mark_as_read?
    return false unless user.security_charter_accepted?

    user == record.user || user.admin?
  end
end
