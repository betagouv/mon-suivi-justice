class AppointmentsReschedulesPolicy < ApplicationPolicy
  include AppointmentHabilityCheckable
  def new?
    return false unless record.booked?

    hability_check && user.organization.in?([record.organization, record.creating_organization])
  end

  def create?
    return false unless record.created?

    hability_check && user.organization.in?([record.organization, record.creating_organization])
  end
end
