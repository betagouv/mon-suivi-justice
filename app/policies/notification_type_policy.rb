class NotificationTypePolicy < ApplicationPolicy
  def reset?
    return false unless user.admin?
    
    record.is_default == false && record.still_default == false
  end
end