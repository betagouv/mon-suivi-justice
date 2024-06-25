class DivestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.local_admin?

      scope.where(organization: user.organization)
    end
  end

  def create?
    return true if user.can_use_inter_ressort?
    record.organization == user.organization
  end
end
