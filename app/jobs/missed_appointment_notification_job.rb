class MissedAppointmentNotificationJob < ApplicationJob
  def perform
    AppointmentType.find_each do |appointment_type|
      next if NotificationType.exists? appointment_type: appointment_type, role: :no_show

      create_notification_type(appointment_type)
    end
    Appointment.find_each { |appointment| create_notification(appointment) }
  end

  private

  def create_notification_type(appointment_type)
    NotificationType.create(
      appointment_type: appointment_type, role: :no_show,
      template: 'Vous avez manqué votre RDV avec le SPIP, veuillez contacter votre conseiller.'
    )
  end

  def create_notification(appointment)
    Notification.create(
      appointment: appointment, role: :no_show,
      template: 'Vous avez manqué votre RDV avec le SPIP, veuillez contacter votre conseiller.',
      content: 'Vous avez manqué votre RDV avec le SPIP, veuillez contacter votre conseiller.'
    )
  end
end
