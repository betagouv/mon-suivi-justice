class SlotTypePolicy < ApplicationPolicy
  def index?
    user.admin? || user.local_admin? || user.dpip?
  end

  def show?
    user.admin? || user.local_admin? || user.dpip?
  end

  def new?
    user.admin? || user.local_admin? || user.dpip?
  end

  def create?
    user.admin? || user.local_admin? || user.dpip?
  end

  def edit?
    user.admin? || user.local_admin? || user.dpip?
  end

  def update?
    user.admin? || user.local_admin? || user.dpip?
  end

  def destroy?
    user.admin? || user.local_admin? || user.dpip?
  end
end
