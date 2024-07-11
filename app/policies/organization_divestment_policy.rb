class OrganizationDivestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.can_manage_divestments?

      scope.where(organization: user.organization)
    end
  end

  def index?
    return false unless user.security_charter_accepted?

    user.can_manage_divestments?
  end

  def edit?
    update?
  end

  def update?
    return false unless user.security_charter_accepted? && user.can_manage_divestments?
    return false unless record.convict.valid?

    record.pending? && user.organization == record.organization
  end
end
