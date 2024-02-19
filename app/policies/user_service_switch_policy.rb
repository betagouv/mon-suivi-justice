class UserServiceSwitchPolicy < ApplicationPolicy
  def create?
    return false unless user.security_charter_accepted?

    (user.local_admin_spip? || user.overseer? || user.psychologist?) && user.headquarter.present?
  end
end
