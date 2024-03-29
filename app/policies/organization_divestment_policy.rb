class OrganizationDivestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return [] unless user.local_admin?

      scope.where(organization: user.organization)
    end
  end

  def index?
    return false unless user.security_charter_accepted?

    user.local_admin?
  end

  def show?
    return false unless user.security_charter_accepted?

    user.local_admin?
  end

  def validate?
    return false unless user.security_charter_accepted?
    return false unless user.local_admin?
    return record.pending? && user.organization == record.organization unless record.respond_to?(:any?)

    record.any? { |divestment| divestment.organization == user.organization }
  end
end
