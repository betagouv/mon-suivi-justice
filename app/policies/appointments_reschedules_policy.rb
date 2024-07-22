class AppointmentsReschedulesPolicy < ApplicationPolicy
  include AppointmentHabilityCheckable

  # rubocop:disable Metrics/AbcSize
  def new?
    return false unless user.security_charter_accepted?
    return false unless record.booked?
    return false unless record.slot.datetime.after?(Time.zone.now)

    hability_check && user.organization.in?([record.organization, record.creating_organization])
  end
  # rubocop:enable Metrics/AbcSize

  def create?
    return false unless user.security_charter_accepted?

    return false unless record.created?

    hability_check && user.organization.in?([record.organization, record.creating_organization])
  end
end
