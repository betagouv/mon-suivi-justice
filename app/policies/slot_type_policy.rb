class SlotTypePolicy < ApplicationPolicy
  ALLOWED_TO_INTERACT = %w[admin local_admin jap dir_greff_bex dir_greff_sap greff_sap dpip].freeze

  def index?
    return false unless user.security_charter_accepted?

    ALLOWED_TO_INTERACT.include?(user.role)
  end

  def update?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def new?
    return false unless user.security_charter_accepted?

    ALLOWED_TO_INTERACT.include?(user.role)
  end

  def create?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def destroy?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def destroy_all?
    return false unless user.security_charter_accepted?

    return false unless ALLOWED_TO_INTERACT.include?(user.role)

    record.to_a.all? { |slot_type| check_ownership?(slot_type) }
  end

  def check_ownership?(slot_type = record)
    slot_type.place.organization == user.organization
  end
end
