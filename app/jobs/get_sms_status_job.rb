class GetSmsStatusJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification_id)
    notification = Notification.find(notification_id)

    return if %w[received failed].include?(notification.state)

    SendinblueAdapter.new.get_sms_status(notification)
  end
end
