class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.local_admin?
        scope.in_department(user.organization.departments.first)
      end
    end
  end

  def index?
    user.admin? || user.local_admin?
  end

  def update?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || user.local_admin?
  end

  def destroy?
    user.admin? || user.local_admin?
  end
end
