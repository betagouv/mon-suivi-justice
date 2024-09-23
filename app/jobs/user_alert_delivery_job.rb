class UserAlertDeliveryJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(content, organization_id, role, alert_type, user)
    @errors = []

    @organization = Organization.find_by id: organization_id
    recipients = find_recipients(role)

    UserAlert.create!(content:, alert_type:, users: recipients, roles: role.present? ? role : 'Tous les rôles',
                      services: @organization.present? ? @organization.name : 'Tous les services')
  rescue StandardError => e
    @errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user:, content:, organization: @organization, role:, number_of_recipients: recipients.count,
                     alert_type:, errors: @errors).user_alert_delivery_report.deliver_later
  end

  private

  def find_recipients(role)
    query_conditions = {}
    query_conditions[:organization] = @organization if @organization.present?
    query_conditions[:role] = role if role.present?

    User.where(query_conditions)
  end
end
