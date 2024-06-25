class SlotPolicy < ApplicationPolicy
  ALLOWED_TO_INTERACT = %w[admin local_admin jap dir_greff_bex dir_greff_sap greff_sap dpip overseer secretary_court].freeze

  class Scope < Scope
    def resolve
      if user.admin?
        scope.available.in_jurisdiction(user.organization)
      elsif ALLOWED_TO_INTERACT.include? user.role
        scope.available.in_organization(user.organization)
      end
    end
  end

  def index?
    return false unless user.security_charter_accepted?

    ALLOWED_TO_INTERACT.include?(user.role)
  end

  def edit?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def new?
    return false unless user.security_charter_accepted?

    ALLOWED_TO_INTERACT.include?(user.role)
  end

  def update?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def show?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def create?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def destroy?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def update_all?
    return false unless user.security_charter_accepted?

    return false unless ALLOWED_TO_INTERACT.include?(user.role)

    record.to_a.all? { |slot| check_ownership?(slot) }
  end

  def select?
    user.security_charter_accepted?
  end

  def check_ownership?(slot = record)
    if user.admin?
      return [user.organization, *user.organization.linked_organizations].include?(slot.agenda.place.organization)
    end

    slot.agenda.place.organization == user.organization
  end
end
