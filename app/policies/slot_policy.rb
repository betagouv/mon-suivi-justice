class SlotPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.local_admin? || user.bex? || user.sap? || user.dpip?
        scope.in_department(user.organization.departments.first)
      end
    end
  end

  def index?
    user.admin? || user.local_admin? || user.dpip?
  end

  def update?
    user.admin? || user.local_admin? || user.dpip?
  end

  def show?
    user.admin? || user.local_admin? || user.dpip?
  end

  def create?
    user.admin? || user.local_admin? || user.dpip?
  end

  def destroy?
    user.admin? || user.local_admin? || user.dpip?
  end

  def select?
    true
  end
end
