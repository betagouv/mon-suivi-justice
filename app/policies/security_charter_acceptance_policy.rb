class SecurityCharterAcceptancePolicy < ApplicationPolicy
  def new?
    !user.security_charter_accepted?
  end

  def create?
    !user.security_charter_accepted?
  end
end
