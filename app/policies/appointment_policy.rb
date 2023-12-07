class AppointmentPolicy < ApplicationPolicy
  include AppointmentHabilityCheckable

  class Scope < Scope
    def resolve
      # for bex and localadmin, we should check appointment_type like for sap
      # currently bex user can see all spip appointments
      if user.work_at_bex? || user.local_admin_tj?
        scope.in_jurisdiction(user.organization).or(scope.created_by_organization(user.organization)).distinct
      elsif user.work_at_sap?
        scope.joins(:slot,
                    convict: :organizations).in_organization(user.organization)
             .or(scope.created_by_organization(user.organization)
                      .joins(slot: { agenda: :place })
                      .where({ 'appointment_types.name': AppointmentType.used_at_sap? }))
             .distinct
      else
        scope.in_organization(user.organization)
      end
    end
  end

  def index?
    true
  end

  def show?
    ownership_check && hability_check
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
    ownership_check && hability_check
  end

  def new?
    true
  end

  def create?
    # we don't use ownership_check here because otherwise the creating_organization
    # condition would always make it true and we need to handle inter ressort for bex
    return true if user.work_at_bex? && user.organization.use_inter_ressort
    return record.in_jurisdiction?(user.organization) if user.work_at_bex? || user.local_admin_tj?
    # Les agents SAP doivent pouvoir prendre des convocations SAP DDSE au SPIP
    return record.in_jurisdiction?(user.organization) if user.work_at_sap? && record.appointment_type.ddse?

    record.in_organization?(user.organization)
  end

  def destroy?
    ownership_check && hability_check
  end

  def cancel?
    return false unless record.booked?

    ownership_check && hability_check
  end

  def fulfil?
    ownership_check && appointment_fulfilment
  end

  def miss?
    ownership_check && appointment_fulfilment
  end

  def excuse?
    ownership_check && appointment_fulfilment
  end

  def rebook?
    ownership_check && appointment_fulfilment
  end

  def prepare?
    true
  end

  def fulfil_old?
    ownership_check && appointment_fulfilment(allow_fulfil_old: true)
  end

  def excuse_old?
    ownership_check && appointment_fulfilment(allow_fulfil_old: true)
  end

  def rebook_old?
    ownership_check && appointment_fulfilment(allow_fulfil_old: true)
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

  def ownership_check
    return true if record.created_by_organization?(user.organization)

    return record.in_jurisdiction?(user.organization) if user.work_at_bex? || user.local_admin_tj?

    record.in_organization?(user.organization)
  end
end
