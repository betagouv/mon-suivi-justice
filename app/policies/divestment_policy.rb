class DivestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.can_manage_divestments?

      scope.where(organization: user.organization)
    end
  end

  def create?
    return false unless user.security_charter_accepted?
    return true if user.can_use_inter_ressort?

    record.organization == user.organization
  end
end
