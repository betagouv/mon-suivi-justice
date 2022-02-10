module NotificationFactory
  def self.perform(appointment)
    notif_types = appointment.slot.appointment_type.notification_types

    notif_types.each do |notif_type|
      template = setup_template(notif_type.template)

      Notification.create!(
        appointment: appointment,
        role: notif_type.role,
        reminder_period: notif_type.reminder_period,
        content: template % sms_data(appointment.slot)
      )
    end
  end

  def self.setup_template(notif_type_template)
    notif_type_template.gsub('{', '%{')
                       .gsub('rdv.heure', 'appointment_hour')
                       .gsub('rdv.date', 'appointment_date')
                       .gsub('lieu.nom', 'place_name')
                       .gsub('lieu.adresse', 'place_adress')
                       .gsub('lieu.téléphone', 'place_phone')
                       .gsub('lieu.contact', 'place_contact')
                       .gsub('lieu.lien_info', 'place_preparation_link')
  end

  def self.sms_data(slot)
    {
      appointment_hour: slot.starting_time.to_s(:lettered),
      appointment_date: slot.date.to_s(:base_date_format),
      place_name: slot.place_name,
      place_adress: slot.place_adress,
      place_phone: slot.place_display_phone(spaces: false),
      place_contact: slot.place_contact_detail,
      place_preparation_link: slot.place_preparation_link
    }
  end
end
