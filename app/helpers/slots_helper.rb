module SlotsHelper
  def appointment_types_for_slot_creation(user)
    list = apt_type_list(user)
    after_hearing_organization_types = user.organization.after_hearing_available_appointment_types
    AppointmentType.where(name: list).where(id: after_hearing_organization_types)
  end

  def agendas_for_slot_creation(user)
    user.organization.agendas.includes(:place).kept.select(&:appointment_type_with_slot_types?)
  end

  private

  def apt_type_list(user) # rubocop:disable Metrics/CyclomaticComplexity
    return ['SAP DDSE'] if user.overseer?
    return sap_apt_types if user.work_at_sap?
    return spip_apt_types if user.work_at_spip?
    return bex_apt_types if user.work_at_bex? || user.admin?

    return unless user.local_admin?

    user.organization.spip? ? spip_apt_types : sap_apt_types
  end

  def sap_apt_types
    ["Sortie d'audience SAP"]
  end

  def spip_apt_types
    ["Sortie d'audience SPIP", 'SAP DDSE']
  end

  def bex_apt_types
    ["Sortie d'audience SAP", "Sortie d'audience SPIP", 'SAP DDSE']
  end
end
