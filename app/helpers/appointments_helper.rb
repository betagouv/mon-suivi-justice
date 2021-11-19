module AppointmentsHelper
  def appointment_types_for_user(user)
    condition = if user.work_at_sap? then AppointmentType.new.used_at_sap?
                elsif user.work_at_bex? then AppointmentType.new.used_at_bex?
                elsif user.work_at_spip? then AppointmentType.new.used_at_spip?
                else
                  return AppointmentType.all
                end

    AppointmentType.where(condition)
  end
end
