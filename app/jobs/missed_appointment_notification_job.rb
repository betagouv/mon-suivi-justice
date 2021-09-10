class MissedAppointmentNotificationJob < ApplicationJob
  def perform
    AppointmentType.find_each do |appointment_type|
      next if NotificationType.exists? appointment_type: appointment_type, role: :missed

      create_notification_type(appointment_type)
    end
    Appointment.find_each { |appointment| create_notification(appointment) }
  end

  private

  def create_notification_type(appointment_type)
    NotificationType.create(
      appointment_type: appointment_type, role: :missed,
      template: 'Vous avez manqué votre "RDV suivi", veuillez contacter votre SPIP dans les meilleurs délais.'
    )
  end

  def create_notification(appointment)
    Notification.create(
      appointment: appointment, role: :missed,
      template: 'Vous avez manqué votre "RDV suivi", veuillez contacter votre SPIP dans les meilleurs délais.'
    )
  end
end
