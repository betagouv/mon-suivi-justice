class SlotPolicy < ApplicationPolicy
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

  def select?
    true
  end
end
