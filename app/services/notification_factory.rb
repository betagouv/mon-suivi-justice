module NotificationFactory
  def self.perform(appointment)
    notif_types = appointment.appointment_type.notification_types

    notif_types.each do |notif_type|
      Notification.create!(
        appointment: appointment,
        role: notif_type.role,
        reminder_period: notif_type.reminder_period,
        template: setup_template(notif_type.template)
      )
    end
  end

  def self.setup_template(notif_type_template)
    notif_type_template.gsub('{', '%{')
                       .gsub('rdv.heure', 'appointment_hour')
                       .gsub('rdv.date', 'appointment_date')
                       .gsub('lieu.nom', 'place_name')
                       .gsub('lieu.adresse', 'place_adress')
  end
end
