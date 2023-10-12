class AppointmentPolicy < ApplicationPolicy
  include AppointmentHabilityCheckable

  class Scope < Scope
    def resolve
      if user.work_at_bex?
        scope.in_jurisdiction(user.organization).or(scope.created_by_organization(user.organization)).distinct
      else
        scope.in_organization(user.organization)
      end
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def agenda_jap?
    user.admin? || user.local_admin_tj? || user.work_at_sap? || user.work_at_bex?
  end

  def agenda_sap_ddse?
    user.admin? || user.local_admin? || user.work_at_sap? || user.work_at_bex? || user.overseer? || user.work_at_spip?
  end

  def agenda_spip?
    user.admin? || user.local_admin_spip? || user.work_at_bex? || user.work_at_spip?
  end

  def update?
    hability_check
  end

  def new?
    true
  end

  def create?
    true
  end

  def destroy?
    hability_check
  end

  def cancel?
    return false unless record.booked?

    hability_check
  end

  def fulfil?
    appointment_fulfilment
  end

  def miss?
    appointment_fulfilment
  end

  def excuse?
    appointment_fulfilment
  end

  def rebook?
    appointment_fulfilment
  end

  def prepare?
    true
  end

  def fulfil_old?
    appointment_fulfilment(allow_fulfil_old: true)
  end

  def excuse_old?
    appointment_fulfilment(allow_fulfil_old: true)
  end

  def rebook_old?
    appointment_fulfilment(allow_fulfil_old: true)
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def appointment_fulfilment(allow_fulfil_old: false)
    apt_type = AppointmentType.find(record.slot&.appointment_type_id)
    is_too_old = allow_fulfil_old ? false : record.slot.date < 6.months.ago
    is_in_organization = record.slot.place.organization == user.organization

    if !is_in_organization || is_too_old || user.work_at_bex? then false
    elsif user.work_at_sap? then AppointmentType.used_at_sap?.include? apt_type.name
    elsif user.work_at_spip? then AppointmentType.used_at_spip?.include? apt_type.name
    else
      true
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
