class SmsDeliveryService
  attr_reader :notification

  def initialize(notification)
    @notification = notification.reload
  end

  def send_sms
    validate_notification_state
    return handle_unsendable_notification unless notification.can_be_sent?

    final_content = notification.generate_content
    notification.update(content: final_content) unless final_content == notification.content

    response = LinkMobilityAdapter.new(notification).send_sms

    update_state_from_response(response)
  end

  private

  def validate_notification_state
    raise "Notification (id: #{notification.id}) state still created" if notification.created?
  end

  def handle_unsendable_notification
    notification.handle_unsent!
  end

  def update_state_from_response(response)
    notification.update!(external_id: response.external_id) if response.external_id.present?

    if response.success
      notification.mark_as_sent!
    else
      manage_failure(response)
    end
  end

  def manage_failure(response)
    notification.increment!(:failed_count)
    notification.update!(response_code: response.code, target_phone: notification.convict_phone)

    raise SmsDeliveryError.new(response.code, response.message) if response.retry_if_failed

    notification.mark_as_failed!
  end
end
