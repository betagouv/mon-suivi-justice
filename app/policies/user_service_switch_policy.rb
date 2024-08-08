class UserServiceSwitchPolicy < ApplicationPolicy
  def create?
    return false unless user.security_charter_accepted?
    return true if user.admin?

    user_has_required_role? && user_in_same_headquarter?
  end

  private

  def user_has_required_role?
    user.local_admin_spip? || user.overseer? || user.psychologist?
  end

  def user_in_same_headquarter?
    user.headquarter&.organizations&.include?(record.organization)
  end
end
