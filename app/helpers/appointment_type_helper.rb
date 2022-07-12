module AppointmentTypeHelper
  def formated_orgas_for_select(orgas)
    formated = [[I18n.t('default'), nil]]

    orgas.each do |orga|
      formated << [orga.name, orga.id]
    end

    formated
  end

  def edit_notification_type_page_title(appointment_type, organization)
    if organization.nil?
      "#{appointment_type.name} / Défaut"
    else
      "#{appointment_type.name} / #{organization.name}"
    end
  end
end
