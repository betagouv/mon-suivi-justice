class AgendaPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.local_admin? || user.work_at_bex?
        scope.in_jurisdiction(user.organization)
      else
        scope.in_organization(user.organization)
      end
    end
  end

  def create?
    user.admin? || user.local_admin? || user.greff_sap?
  end

  def update?
    user.admin? || user.local_admin? || user.greff_sap?
  end

  def destroy?
    user.admin? || user.local_admin? || user.greff_sap?
  end
end
