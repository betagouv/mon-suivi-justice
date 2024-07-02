class SmsDeliveryJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification_id)
    notification = notification_id.is_a?(Integer) ? Notification.find(notification_id) : notification_id
    return if notification.canceled?

    unless notification.convict.can_receive_sms?
      notification.mark_as_unsent if notification.programmed?
      return
    end

    notification.send_then if notification.programmed?

    LinkMobilityAdapter.new.send_sms(notification)
  end
end
