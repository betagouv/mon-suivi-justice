class AgendaPolicy < ApplicationPolicy
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
