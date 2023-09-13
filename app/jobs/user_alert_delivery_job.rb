class UserAlertDeliveryJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(comment, organization_id, role, user)
    @errors = []

    @organization = Organization.find_by id: organization_id

    query_conditions = {}
    query_conditions[:organization] = @organization if @organization.present?
    query_conditions[:role] = role if role.present?

    recipients = User.where(query_conditions)
    notification = UserAlertNotification.with(comment:)

    notification.deliver(recipients)
  rescue StandardError => e
    @errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user:, comment:, organization: @organization,
                     errors: @errors).user_alert_delivery_report.deliver_later
  end
end
