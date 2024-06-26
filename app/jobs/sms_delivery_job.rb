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

    LinkMobilityAdapter.new.send_sms(notification)
    # GetSmsStatusJob.set(wait: 5.hours).perform_later(notification.id)
  end
end
