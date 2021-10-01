class PlacePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.in_organization(organization)
      end
    end
  end

  def index?
    user.admin?
  end

  def update?
    user.admin?
  end

  def show?
    user.admin?
  end

  def create?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
