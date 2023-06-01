module SlotsHelper
  def appointment_types_for_slot_creation(user)
    list = apt_type_list(user)
    AppointmentType.where(name: list)
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
    ["Sortie d'audience SAP"]
  end

  def spip_apt_types
    ["Sortie d'audience SPIP", 'SAP DDSE']
  end

  def bex_apt_types
    ["Sortie d'audience SAP", "Sortie d'audience SPIP", 'SAP DDSE']
  end

  def valid_date_for_slot(place, date)
    before_transfer_in = place.transfert_in && date < place.transfert_in.date
    after_transfer_out = place.transfert_out && date >= place.transfert_out.date

    !(before_transfer_in || after_transfer_out)
  end
end
