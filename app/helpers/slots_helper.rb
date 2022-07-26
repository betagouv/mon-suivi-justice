module SlotsHelper
  def appointment_types_for_slot_creation(user)
    list = if user.work_at_sap? then "Sortie d'audience SAP"
           elsif user.work_at_spip? then "Sortie d'audience SPIP"
           elsif user.work_at_bex? || user.admin? then ["Sortie d'audience SAP",
                                                        "Sortie d'audience SPIP"]
           # assuming local_admin does not work at bex or spip (TODO: need to clarify roles) :
           elsif user.local_admin?
             user.organization.organization_type == 'spip' ? "Sortie d'audience SPIP" : "Sortie d'audience SAP"
           end
    AppointmentType.where(name: list)
  end

  def agendas_for_slot_creation(user)
    if user.work_at_bex? || user.admin?
      Agenda.in_department(user.organization.departments.first).select(&:appointment_type_with_slot_types?)
    else
      Agenda.in_organization(user.organization).select(&:appointment_type_with_slot_types?)
    end
  end
end
