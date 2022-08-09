class SteeringPolicy < ApplicationPolicy
  def user_app_stats?
    user.admin?
  end

  def convict_app_stats?
    user.admin?
  end

  def sda_stats?
    user.admin?
  end
end
