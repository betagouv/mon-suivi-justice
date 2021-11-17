module NotificationFactory
  def self.perform(appointment)
    notif_types = appointment.slot.appointment_type.notification_types

    notif_types.each do |notif_type|
      template = setup_template(notif_type.template)

      Notification.create!(
        appointment: appointment,
        role: notif_type.role,
        reminder_period: notif_type.reminder_period,
        content: template % sms_data(appointment)
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
  end

  def self.sms_data(appointment)
    slot = appointment.slot
    {
      appointment_hour: slot.starting_time.to_s(:lettered),
      appointment_date: slot.date.to_s(:base_date_format),
      place_name: slot.agenda.place.name,
      place_adress: slot.agenda.place.adress,
      place_phone: slot.agenda.place.display_phone(spaces: false)
    }
  end
end
