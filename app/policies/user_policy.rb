class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def update?
    true
  end

  def show?
    true
  end

  def create?
    user.admin?
  end

  def edit_password?
    true
  end

  def update_password?
    true
  end

  def destroy?
    user.admin?
  end
end
