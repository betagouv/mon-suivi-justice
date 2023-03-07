class SmsDeliveryJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification_id)
    notification = notification_id.is_a?(Integer) ? Notification.find(notification_id) : notification_id
    return if notification.canceled?
    return if notification.convict_phone.nil? || notification.convict_phone.empty?

    notification.send_then if notification.programmed?

    LinkMobilityAdapter.new.send_sms(notification)
    # GetSmsStatusJob.set(wait: 5.hours).perform_later(notification.id)
  end
end
