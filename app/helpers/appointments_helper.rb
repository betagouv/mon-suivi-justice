module AppointmentsHelper
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize
  def appointment_types_for_user_role(user)
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

  # rubocop:enable Metrics/PerceivedComplexity, Metrics/AbcSize

  def spip_user_appointments_types_array(user)
    if user.can_have_appointments_assigned?
      AppointmentType.assignable.pluck(:name)
    else
      AppointmentType.used_at_spip?
    end
  end

  def current_sort_column
    params[:q]&.fetch(:s, '')&.split&.first
  end

  def sort_link_with_expandable_arrow(column, text)
    link = sort_link(@q, column, text, default_order: :desc)
    unless current_sort_column == column
      svg = image_tag('expand-up-down-line.svg', width: 15, style: 'margin-left: 5px')
    end
    content = link + svg.to_s

    "<span class='sort-link-inline'>#{ERB::Util.html_escape(content)}</span>".html_safe
  end
end
