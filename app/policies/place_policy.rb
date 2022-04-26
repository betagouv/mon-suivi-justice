class PlacePolicy < ApplicationPolicy
  ALLOWED_TO_EDIT = %w[admin local_admin jap dir_greff_bex dir_greff_sap dpip].freeze

  class Scope < Scope
    def resolve
      if user.admin? || user.local_admin? || user.work_at_bex?
        # TODO: there is for the moment only one department per organization.
        # When there will be more, this logic will need to be adapted.
        scope.in_department(user.organization.departments.first)
      else
        scope.in_organization(user.organization)
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
