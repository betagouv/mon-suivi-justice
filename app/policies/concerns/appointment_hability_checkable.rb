module AppointmentHabilityCheckable
  extend ActiveSupport::Concern

  def hability_check
    apt_type = AppointmentType.find(record.slot&.appointment_type_id)

    if user.work_at_sap? then AppointmentType.used_at_sap?.include? apt_type.name
    elsif user.work_at_spip? then AppointmentType.used_at_spip?.include? apt_type.name
    elsif user.work_at_bex? then AppointmentType.used_at_bex?.include? apt_type.name
    else
      true
    end
  end
end
