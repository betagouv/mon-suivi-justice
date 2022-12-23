module AppointmentsHelper
  # rubocop:disable Metrics/MethodLength
  def appointment_types_for_user(user)
    if user.work_at_sap?
      list = AppointmentType.used_at_sap?
    elsif user.work_at_bex?
      list = AppointmentType.used_at_bex?
    elsif user.work_at_spip?
      list = if %w[cpip secretary_spip educator psychologist].include? user.role
               AppointmentType.used_at_spip? - ['SAP DDSE']
             else
               AppointmentType.used_at_spip?
             end
    else
      return AppointmentType.all
    end

    AppointmentType.where(name: list)
  end
  # rubocop:enable Metrics/MethodLength

  def my_appointment_types_for_user(user)
    list = if user.work_at_sap? then AppointmentType.used_at_sap?
           elsif user.work_at_bex? then AppointmentType.used_at_bex?
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
      AppointmentType.used_at_spip?
    end
  end

  def waiting_line_title(organization)
    if %w[cpip dpip].include?(current_user.role)
      t('appointments.waiting_line.for_a_user')
    else
      t('appointments.waiting_line.for_a_service', orga: organization.name)
    end
  end
end
