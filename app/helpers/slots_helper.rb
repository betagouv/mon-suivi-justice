module SlotsHelper
  def appointment_types_for_slot_creation(user)
    list = apt_type_list(user)
    AppointmentType.where(name: list)
  end

  def agendas_for_slot_creation(user)
    if user.work_at_bex? || user.admin?
      Agenda.in_departments(user.organization.departments).select(&:appointment_type_with_slot_types?)
    else
      Agenda.in_organization(user.organization).select(&:appointment_type_with_slot_types?)
    end
  end

  private

  def apt_type_list(user)
    if user.work_at_sap? then sap_apt_types
    elsif user.work_at_spip? then spip_apt_types
    elsif user.work_at_bex? || user.admin? then bex_apt_types
    # assuming local_admin does not work at bex or spip (TODO: need to clarify roles) :
    elsif user.local_admin?
      user.organization.organization_type == 'spip' ? spip_apt_types : sap_apt_types
    end
  end

  def sap_apt_types
    ["Sortie d'audience SAP", 'SAP DDSE']
  end

  def spip_apt_types
    ["Sortie d'audience SPIP", 'SAP DDSE']
  end

  def bex_apt_types
    ["Sortie d'audience SAP", "Sortie d'audience SPIP", 'SAP DDSE']
  end
end
