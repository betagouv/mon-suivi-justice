class SmsDeliveryJob < ApplicationJob
  sidekiq_options retry: 5
  
  queue_as :default

  def perform(notification)
    SendinblueAdapter.new.send_sms(notification)
  end
end
