class UserUserAlertPolicy < ApplicationPolicy
  def mark_as_read?
    user == record.user || user.admin?
  end
end
