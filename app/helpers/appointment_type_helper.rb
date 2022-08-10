module AppointmentTypeHelper
  def formated_orgas_for_select(orgas)
    formated = [[I18n.t('default'), nil]]

    orgas.each do |orga|
      formated << [orga.name, orga.id]
    end

    formated
  end

  def template_status(notif_type)
    if notif_type.is_default == true
      I18n.t('appointment_type.default_template')
    elsif notif_type.still_default == true
      I18n.t('appointment_type.still_default_template')
    elsif notif_type.still_default == false
      I18n.t('appointment_type.custom_template')
    end
  end

  def template_updated_at(notif_type)
    date = notif_type.updated_at.strftime('%d/%m/%Y à %kh%M')

    if notif_type.is_default == true || notif_type.still_default == false
      I18n.t('appointment_type.updated_at', date: date)
    elsif notif_type.still_default == true
      I18n.t('appointment_type.imported_at', date: date)
    end
  end
end
