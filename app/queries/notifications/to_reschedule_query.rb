module Notifications
  class ToRescheduleQuery
    def call
      notifications_to_be_sent.where.not(id: scheduled_sms_delivery_jobs_notif_ids)
    end

    private

    def notifications_to_be_sent
      cancelation_notifications
        .or(no_show_notifications)
        .or(other_notifications)
    end

    def cancelation_notifications
      Notification.retryable
                  .appointment_after_today
                  .where(appointments: { state: 'canceled' })
                  .where(state: 'programmed', role: 'cancelation')
    end

    def no_show_notifications
      Notification.retryable
                  .appointment_recently_past
                  .where(appointments: { state: 'no_show' })
                  .where(state: 'programmed', role: 'no_show')
    end

    def other_notifications
      Notification.retryable
                  .appointment_after_today
                  .where(appointments: { state: 'booked' })
                  .where(state: 'programmed', role: %w[summon reminder reschedule])
    end

    def scheduled_sms_delivery_jobs_notif_ids
      Sidekiq::ScheduledSet.new.map do |job|
        job.item.dig('args', 0, 'arguments', 0) if job.item['wrapped'] == 'SmsDeliveryJob'
      end.compact
    end
  end
end
