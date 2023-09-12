class UserAlertPolicy < ApplicationPolicy
  def mark_as_read?
    user == record.recipient || user.admin?
  end
end
