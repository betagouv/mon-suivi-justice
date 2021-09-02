class SmsDeliveryJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification)
    return if notification.canceled?

    notification.send_then if notification.programmed?

    SendinblueAdapter.new.send_sms(notification)
    GetSmsStatusJob.perform_later(notification)
  end
end
