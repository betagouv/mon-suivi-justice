class GetSmsStatusJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification)
    return if %w[received failed].include?(notification.state)

    SendinblueAdapter.new.get_sms_status(notification)
    GetSmsStatusJob.perform_later(notification)
  end
end
