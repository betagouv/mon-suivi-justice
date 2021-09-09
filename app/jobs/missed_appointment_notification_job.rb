class MissedAppointmentNotificationJob < ApplicationJob
  def perform
    AppointmentType.find_each do |appointment_type|
      next if NotificationType.exists? appointment_type: appointment_type, role: :missed

      NotificationType.create(
        appointment_type: appointment_type, role: :missed,
        template: 'Vous avez manqué votre "RDV suivi", veuillez contacter votre SPIP dans la meilleurs délais.'
      )
    end

    todo spec pour below :

    Appointment.find_each do |appointment|
      Notification.create(
        appointment: appointment,
        role: :missed,
        template: 'Vous avez manqué votre "RDV suivi", veuillez contacter votre SPIP dans la meilleurs délais.'
      )
    end
  end
end
