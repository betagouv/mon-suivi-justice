class AgendaPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.local_admin? || user.work_at_bex?
        scope.in_departments(user.organization.departments)
      else
        scope.in_organization(user.organization)
      end
    end
  end

  def create?
    user.admin? || user.local_admin?
  end

  def update?
    user.admin? || user.local_admin?
  end

  def destroy?
    user.admin?
  end
end
