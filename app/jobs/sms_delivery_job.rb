class SmsDeliveryJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification_id)
    notification = notification_id.is_a?(Integer) ? Notification.find(notification_id) : notification_id

    SmsDeliveryService.new(notification).send_sms
  end
end
