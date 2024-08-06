class SmsDeliveryService
  attr_reader :notification

  def initialize(notification)
    @notification = notification.reload
  end

  def send_sms
    raise "Notification (id: #{notification.id}) state still created" if notification.created?

    unless sms_can_be_sent?
      notification.handle_unsent!
      return
    end

    response = LinkMobilityAdapter.new(notification).send_sms

    update_state_from_response(response)
  end

  private

  def sms_can_be_sent?
    notification.convict.can_receive_sms? && notification.can_be_sent?
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

    raise SmsDeliveryError.new(response.code, response.message) if response.retry_if_failed?

    notification.mark_as_failed!
  end
end
