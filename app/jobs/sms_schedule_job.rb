class SmsScheduleJob < ApplicationJob
  sidekiq_options retry: 10

  queue_as :default

  def perform
    Notification.ready_to_send.each { |notification| SmsDeliveryJob.perform_later(notification.id) }
  end
end
