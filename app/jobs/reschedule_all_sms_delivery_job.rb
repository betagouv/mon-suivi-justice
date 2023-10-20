class RescheduleSmsDeliveryJob < ApplicationJob
  queue_as :default

  def perform(start_date = Date.today)
    scheduled_notification_ids = fetch_scheduled_notification_ids
    notifs = fetch_relevant_notifications(start_date)
    rescheduled_jobs_count = process_notifications(notifs, scheduled_notification_ids)

    puts rescheduled_jobs_count
    puts rescheduled_jobs_count.values.sum
  end

  private

  def fetch_scheduled_notification_ids
    Sidekiq::ScheduledSet.new.map do |job|
      job.item.dig('args', 0, 'arguments', 0) if job.item['wrapped'] == 'SmsDeliveryJob'
    end.compact.to_set
  end

  def fetch_relevant_notifications(start_date)
    Notification.joins(appointment: %i[slot convict])
                .where('slots.date > ?', start_date)
                .where(appointments: { state: 'booked' })
                .where(convicts: { no_phone: false })
                .where(state: 'programmed')
  end

  def process_notifications(notifs, scheduled_notification_ids)
    rescheduled_jobs_count = Hash.new(0)

    notifs.each do |notif|
      next if scheduled_notification_ids.include?(notif.id)

      rescheduled_jobs_count[notif.appointment.slot.date] += 1
      SmsDeliveryJob.set(wait_until: notif.delivery_time)
                    .perform_later(notif.id)
    end

    rescheduled_jobs_count
  end
end
