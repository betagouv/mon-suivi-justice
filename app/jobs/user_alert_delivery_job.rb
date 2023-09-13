class UserAlertDeliveryJob < ApplicationJob
  queue_as :default

  def perform(comment, organization_id, role)
    @errors = []

    @organization = Organization.find(organization_id)

    recipients = User.where(organization_id:, role:)
    notification = UserAlertNotification.with(comment:)

    notification.deliver(recipients)
  rescue StandardError => e
    @errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(comment:, organization:, import_errors:).user_alert_delivery_report.deliver_later
  end
end
