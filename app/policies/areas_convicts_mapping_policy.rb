class AreasConvictsMappingPolicy < ApplicationPolicy
  def create?
    user.security_charter_accepted?
  end

  def destroy?
    user.security_charter_accepted?
  end
end
