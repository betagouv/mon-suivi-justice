class OrganizationDivestmentPolicy < ApplicationPolicy
  def validate?
    return false unless user.security_charter_accepted?
    return false unless user.local_admin?
    return record.pending? && user.organization == record.organization unless record.respond_to?(:any?)

    record.any? { |divestment| divestment.organization == user.organization }
  end
end
