class UserPolicy < ApplicationPolicy
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
