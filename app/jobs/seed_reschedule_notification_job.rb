class SeedRescheduleNotificationJob < ApplicationJob
  def perform(appointment_id)
    appointment = Apppointment.find_by id: appointment_id
    return unless appointment

    notification_type = appointment.appointment_type.notification_types.find_by(role: 'reschedule')
    template = setup_template(notification_type.template) % sms_data(appointment)
    Notification.create appointment: appointment, role: 'reschedule', template: template
  end

  private

  def setup_template(notif_type_template)
    notif_type_template.gsub('{', '%{')
                       .gsub('rdv.heure', 'appointment_hour')
                       .gsub('rdv.date', 'appointment_date')
                       .gsub('lieu.nom', 'place_name')
                       .gsub('lieu.adresse', 'place_adress')
                       .gsub('lieu.téléphone', 'place_phone')
  end

  def sms_data(appointment)
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
