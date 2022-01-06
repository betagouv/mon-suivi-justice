class AgendaPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.local_admin?  || user.bex?
        scope.in_department(user.organization.departments.first)
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
