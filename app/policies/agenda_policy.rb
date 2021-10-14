class AgendaPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.bex? || user.sap?
        scope.all
      else
        scope.in_organization(organization)
      end
    end
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
