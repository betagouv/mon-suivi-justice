class UserServiceSwitchPolicy < ApplicationPolicy
  def create?
    (user.local_admin_spip? || user.overseer? || user.psychologist?) && user.headquarter.present?
  end
end