class AppointmentTypePolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def update?
    check_ownership?
  end

  def show?
    check_ownership?
  end

  def create?
    check_ownership?
  end

  def destroy?
    check_ownership?
  end

  def check_ownership?
    return true if user.admin?

    record.organization == user.organization
  end
end
