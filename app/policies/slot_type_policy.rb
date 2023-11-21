class SlotTypePolicy < ApplicationPolicy
  ALLOWED_TO_EDIT = %w[admin local_admin jap dir_greff_bex dir_greff_sap greff_sap dpip].freeze

  def index?
    ALLOWED_TO_EDIT.include?(user.role)
  end

  def update?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
  end

  def show?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
  end

  def create?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
  end

  def destroy?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
  end

  def select?
    true
  end

  def check_ownership?
    record.place.organization == user.organization
  end
end
