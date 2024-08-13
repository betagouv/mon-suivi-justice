class AppointmentPolicy < ApplicationPolicy
  include AppointmentHabilityCheckable

  class Scope < Scope
    # rubocop:disable Metrics/MethodLength
    def resolve
      if user.work_at_bex?
        scope.in_jurisdiction(user.organization).joins(slot: [{ agenda: :place },
                                                              :appointment_type])
             .where({ 'appointment_types.name': AppointmentType.used_at_bex? })
             .or(scope.created_by_organization(user.organization).joins(slot: [{ agenda: :place },
                                                                               :appointment_type])).distinct
      elsif user.local_admin_tj?
        scope.in_jurisdiction(user.organization).joins(slot: [{ agenda: :place },
                                                              :appointment_type])
             .where({ 'appointment_types.name': AppointmentType.used_by_local_admin_tj? })
             .or(scope.created_by_organization(user.organization).joins(slot: [{ agenda: :place },
                                                                               :appointment_type])).distinct
      elsif user.work_at_sap?
        scope.joins(:slot,
                    convict: :organizations).in_organization(user.organization)
             .or(scope.created_by_organization(user.organization)
                      .joins(slot: [{ agenda: :place }, :appointment_type])
                      .where({ 'appointment_types.name': AppointmentType.used_at_sap? }))
             .distinct
      else
        scope.in_organization(user.organization)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def index?
    user.security_charter_accepted?
  end

  def show?
    return false unless user.security_charter_accepted?

    ownership_check && hability_check
  end

  def agenda_jap?
    return false unless user.security_charter_accepted?

    user.admin? || user.local_admin_tj? || user.work_at_sap? || user.work_at_bex?
  end

  def agenda_sap_ddse?
    return false unless user.security_charter_accepted?

    user.admin? || user.local_admin? || user.work_at_sap? || user.work_at_bex? || user.overseer? || user.work_at_spip?
  end

  def agenda_spip?
    user.security_charter_accepted?
  end

  def update?
    return false unless user.security_charter_accepted?

    ownership_check && hability_check
  end

  def new?
    user.security_charter_accepted?
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def create?
    return false unless user.security_charter_accepted?

    convict_policy = Pundit.policy(user, record.convict)
    return false unless convict_policy.no_divestment_or_convokable_nonetheless?

    # we don't use ownership_check here because otherwise the creating_organization
    # condition would always make it true and we need to handle inter ressort for bex
    return true if user.work_at_bex? && user.organization.use_inter_ressort

    return record.in_jurisdiction?(user.organization) if (user.work_at_bex? && record.appointment_type.used_at_bex?) ||
                                                         (user.local_admin_tj? &&
                                                         record.appointment_type.used_by_local_admin_tj?) ||
                                                         user.admin?
    # Les agents SAP doivent pouvoir prendre des convocations SAP DDSE au SPIP
    return record.in_jurisdiction?(user.organization) if user.work_at_sap? && record.appointment_type.ddse?

    record.in_organization?(user.organization)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def destroy?
    return false unless user.security_charter_accepted?

    ownership_check && hability_check
  end

  def cancel?
    return false unless user.security_charter_accepted?
    return false unless record.booked?
    return false unless record.slot.datetime.after?(Time.zone.now)

    ownership_check && hability_check
  end

  def fulfil?(allow_fulfil_old: false)
    return false unless user.security_charter_accepted?
    return false unless record.in_the_past?
    return false unless record.booked?

    ownership_check && appointment_fulfilment(allow_fulfil_old:)
  end

  def fulfil_old?
    fulfil?(allow_fulfil_old: true)
  end

  def miss?(allow_fulfil_old: false)
    return false unless user.security_charter_accepted?
    return false unless record.in_the_past?
    return false unless record.booked?

    ownership_check && appointment_fulfilment(allow_fulfil_old:)
  end

  def miss_old?
    miss?(allow_fulfil_old: true)
  end

  def excuse?(allow_fulfil_old: false)
    return false unless user.security_charter_accepted?
    return false unless record.booked?

    ownership_check && appointment_fulfilment(allow_fulfil_old:)
  end

  def excuse_old?
    excuse?(allow_fulfil_old: true)
  end

  def change_state?
    fulfil? || miss? || excuse?
  end

  def change_state_old?
    fulfil_old? || miss_old? || excuse_old?
  end

  def rebook?
    return false unless user.security_charter_accepted?

    ownership_check && appointment_fulfilment
  end

  def prepare?
    user.security_charter_accepted?
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

    return record.in_jurisdiction?(user.organization) if (user.work_at_bex? && record.appointment_type.used_at_bex?) ||
                                                         (user.local_admin_tj? &&
                                                           record.appointment_type.used_by_local_admin_tj?)

    record.in_organization?(user.organization)
  end
end
