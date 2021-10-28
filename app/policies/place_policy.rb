class PlacePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.bex? || user.sap?
        scope.all
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
