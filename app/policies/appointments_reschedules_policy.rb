class AppointmentsReschedulesPolicy < ApplicationPolicy
  include AppointmentHabilityCheckable
  def new?
    return false if record.canceled?

    hability_check && user.organization.in?([record.organization, record.creating_organization])
  end

  def create?
    new?
  end
end
