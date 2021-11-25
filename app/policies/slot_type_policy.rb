class SlotTypePolicy < ApplicationPolicy
  ALLOWED_TO_EDIT = %w[admin local_admin jap dir_greff_bex dir_greff_sap greff_sap dpip].freeze

  def index?
    ALLOWED_TO_EDIT.include? user.role
  end

  def show?
    ALLOWED_TO_EDIT.include? user.role
  end

  def new?
    ALLOWED_TO_EDIT.include? user.role
  end

  def create?
    ALLOWED_TO_EDIT.include? user.role
  end

  def edit?
    ALLOWED_TO_EDIT.include? user.role
  end

  def update?
    ALLOWED_TO_EDIT.include? user.role
  end

  def destroy?
    ALLOWED_TO_EDIT.include? user.role
  end
end
