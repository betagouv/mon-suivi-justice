class SmsDeliveryJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification)
    return if notification.canceled?

    notification.send_then if notification.programmed?

    SendinblueAdapter.new.send_sms(notification)
    GetSmsStatusJob.set(wait: 5.hours).perform_later(notification.id)
  end
end
