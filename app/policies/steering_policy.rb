class SteeringPolicy < ApplicationPolicy
  def user_app_stats?
    return false unless user.security_charter_accepted?

    user.admin?
  end

  def convict_app_stats?
    return false unless user.security_charter_accepted?

    user.admin?
  end

  def sda_stats?
    return false unless user.security_charter_accepted?

    user.admin?
  end
end
