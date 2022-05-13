class SmsDeliveryJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification, resent: false)
    return if notification.canceled?

    notification.send_then if notification.programmed?
    SendinblueAdapter.new.send_sms(notification, resent: resent)
    GetSmsStatusJob.set(wait: 5.hours).perform_later(notification.id)
  end
end
