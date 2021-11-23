class PlacePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.bex? || user.sap?
        scope.in_department(user.organization.departments.first)
      else
        scope.in_organization(organization)
      end
    end
  end

  def index?
    user.admin? || user.local_admin?
  end

  def update?
    user.admin? || user.local_admin?
  end

  def show?
    user.admin? || user.local_admin?
  end

  def create?
    user.admin? || user.local_admin?
  end

  def destroy?
    user.admin? || user.local_admin?
  end
end
