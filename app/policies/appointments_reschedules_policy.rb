class AppointmentsReschedulesPolicy < ApplicationPolicy
  def new?
    return false if record.canceled?

    user.organization.in?([record.organization, record.creating_organization])
  end

  def create?
    new?
  end
end
