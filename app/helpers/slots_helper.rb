module SlotsHelper
  def appointment_types_for_slot_creation(user)
    list = if user.work_at_sap? then "Sortie d'audience SAP"
           elsif user.work_at_bex? then "Sortie d'audience SPIP"
           elsif user.work_at_spip? || user.admin? then ["Sortie d'audience SAP", "Sortie d'audience SPIP"]
           end

    AppointmentType.where(name: list)
  end
end
