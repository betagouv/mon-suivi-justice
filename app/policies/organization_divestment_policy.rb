class OrganizationDivestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.local_admin?

      scope.where(organization: user.organization)
    end
  end

  def index?
    return false unless user.security_charter_accepted?

    user.local_admin?
  end

  def edit?
    update?
  end

  def update?
    return false unless user.security_charter_accepted? && user.local_admin?
    return false unless record.convict.valid?

    record.unanswered? && user.organization == record.organization
  end
end
