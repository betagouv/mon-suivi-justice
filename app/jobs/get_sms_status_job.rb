class GetSmsStatusJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform(notification)
    SendinblueAdapter.new.get_sms_status(notification)

    return if %w[received failed].include?(notification.state)

    GetSmsStatusJob.perform_now(notification)
  end
end
