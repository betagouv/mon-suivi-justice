class SlotTypePolicy < ApplicationPolicy
  def index?
    user.admin? || user.local_admin?
  end

  def show?
    user.admin? || user.local_admin?
  end

  def new?
    user.admin? || user.local_admin?
  end

  def create?
    user.admin? || user.local_admin?
  end

  def edit?
    user.admin? || user.local_admin?
  end

  def update?
    user.admin? || user.local_admin?
  end

  def destroy?
    user.admin? || user.local_admin?
  end
end
