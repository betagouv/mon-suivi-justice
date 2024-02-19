class AreasOrganizationsMappingPolicy < ApplicationPolicy
  def create?
    return false unless user.security_charter_accepted?

    user.admin?
  end

  def destroy?
    return false unless user.security_charter_accepted?

    user.admin?
  end
end
