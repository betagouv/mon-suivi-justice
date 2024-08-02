class SmsDeliveryService
  attr_reader :notification

  # tester SMS delivery service
  # Comprendre pourquoi certains SMS sont reschedule
  # Envoyer toutes les 48h un mail à LinkMobility avec les numéros ayant des problèmes de routing
  # Gérer failed summon et reschedule notif dans le service qui manage les fails

  def initialize(notification)
    @notification = notification
  end

  def send_sms
    return unless sms_can_be_send?

    response = LinkMobilityAdapter.new(notification).send_sms

    update_state_from_response(response)
  end

  private

  def sms_can_be_send?
    notification.reload
    raise 'Notification state still created' if notification.created?

    unless notification.convict.can_receive_sms? && notification.can_be_sent?
      handle_unsent_notification
      return false
    end

    true
  end

  def update_state_from_response(response)
    notification.transaction do
      notification.update!(external_id: response.external_id) if response.external_id.present?

      if response.success
        notification.mark_as_sent!
      else
        manage_failure(response)
      end
    end
  end

  def manage_failure(response)
    notification.increment!(:failed_count)

    raise SmsDeliveryError.new(response.code, response.message) if response.retry_if_failed?

    notification.mark_as_failed!
  end

  def handle_unsent_notification
    notification.failed_count.zero? ? notification.mark_as_unsent! : notification.mark_as_failed!
  end
end
