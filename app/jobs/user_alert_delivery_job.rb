class UserAlertDeliveryJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  # rubocop:disable Metrics/MethodLength
  def perform(content, organization_id, role, alert_type, user)
    @errors = []

    @organization = Organization.find_by id: organization_id
    recipients = find_recipients(role)

    # We bypass noticed gem's standard way of creating notifications because we need the rich text field
    recipients.each do |recipient|
      UserAlert.create!(recipient:, content:, read_at: nil, type: 'User', params: { alert_type: })
    rescue StandardError => e
      @errors.push("Error while creating alert for recipient #{recipient.id} (or appropriate identifier): #{e.message}")
    end
  rescue StandardError => e
    @errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user:, content:, organization: @organization, role:, number_of_recipients: recipients.count,
                     alert_type:, errors: @errors).user_alert_delivery_report.deliver_later
  end
  # rubocop:enable Metrics/MethodLength

  private

  def find_recipients(role)
    query_conditions = {}
    query_conditions[:organization] = @organization if @organization.present?
    query_conditions[:role] = role if role.present?

    User.where(query_conditions)
  end
end
