module AppointmentsHelper
  def appointment_types_for_user(user)
    list = if user.work_at_sap? then AppointmentType.new.used_at_sap?
           elsif user.work_at_bex? then AppointmentType.new.used_at_bex?
           elsif user.work_at_spip? then AppointmentType.new.used_at_spip?
           else
             return AppointmentType.all
           end

    AppointmentType.where(name: list)
  end

  def my_appointment_types_for_user(user)
    list = if user.work_at_sap? then AppointmentType.new.used_at_sap?
           elsif user.work_at_bex? then AppointmentType.new.used_at_bex?
           elsif user.work_at_spip?
             spip_user_appointments_types_array(user)
           else
             return AppointmentType.all
           end

    AppointmentType.where(name: list)
  end

  def spip_user_appointments_types_array(user)
    if user.can_have_appointments_assigned?
      AppointmentType.assignable.pluck(:name)
    else
      AppointmentType.new.used_at_spip?
    end
  end
end
