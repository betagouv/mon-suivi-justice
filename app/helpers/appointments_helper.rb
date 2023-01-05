module AppointmentsHelper
  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/AbcSize
  def appointment_types_for_user(user)
    if user.work_at_sap?
      list = AppointmentType.used_at_sap?
    elsif user.work_at_bex?
      list = AppointmentType.used_at_bex?
    elsif user.work_at_spip? || user.local_admin_spip?
      list = if %w[cpip secretary_spip educator psychologist].include? user.role
               AppointmentType.used_at_spip? - ['SAP DDSE']
             else
               AppointmentType.used_at_spip?
             end
    elsif user.local_admin_tj?
      list = AppointmentType.used_at_sap? + AppointmentType.used_at_bex?
    else
      return AppointmentType.all
    end

    AppointmentType.where(name: list)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/AbcSize

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
