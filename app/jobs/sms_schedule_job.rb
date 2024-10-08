class SmsScheduleJob < ApplicationJob
  sidekiq_options retry: 10

  queue_as :default

  def perform
    Notification.ready_to_send.each(&:program_now)
  end
end
