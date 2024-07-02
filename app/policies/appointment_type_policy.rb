class AppointmentTypePolicy < ApplicationPolicy
  def index?
    return false unless user.security_charter_accepted?

    user.admin?
  end

  def update?
    return false unless user.security_charter_accepted?

    user.admin?
  end
end
