class AppointmentPolicy < ApplicationPolicy
  def index?
    user.admin? or user.cpip?
  end

  def update?
    user.admin? or user.bex?
  end

  def show?
    user.admin? or user.cpip?
  end

  def create?
    user.admin? or user.bex?
  end

  def destroy?
    user.admin? or user.bex?
  end
end
