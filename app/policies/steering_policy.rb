class SteeringPolicy < ApplicationPolicy
  def show?
    user.admin?
  end
end
