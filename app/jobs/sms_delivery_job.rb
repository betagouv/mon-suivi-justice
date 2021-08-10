class SmsDeliveryJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification_id, notification_updated_at)
    notification = Notification.find(notification_id)
    return if notification_updated_at != notification.updated_at

    SendinblueAdapter.new.send_sms(notification)
  end
end
