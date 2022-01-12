class PlacePolicy < ApplicationPolicy
  ALLOWED_TO_EDIT = %w[admin local_admin jap dir_greff_bex dir_greff_sap greff_sap dpip].freeze

  class Scope < Scope
    def resolve
      if user.admin? || user.local_admin? || user.work_at_bex?
        scope.in_department(user.organization.departments.first)
      else
        scope.in_organization(organization)
      end
    end
  end

  def index?
    ALLOWED_TO_EDIT.include? user.role
  end

  def update?
    ALLOWED_TO_EDIT.include? user.role
  end

  def show?
    ALLOWED_TO_EDIT.include? user.role
  end

  def create?
    ALLOWED_TO_EDIT.include? user.role
  end

  def destroy?
    ALLOWED_TO_EDIT.include? user.role
  end
end
