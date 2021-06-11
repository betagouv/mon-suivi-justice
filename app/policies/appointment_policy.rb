class AppointmentPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    true
  end

  def show?
    true
  end

  def new_first?
    true
  end

  def create?
    true
  end

  def destroy?
    true
  end
end
