class RescheduleSmsDeliveryJob < ApplicationJob
  queue_as :default
  
  def perform
    # Fetch all scheduled notification IDs from Sidekiq's scheduled set
    scheduled_notification_ids = Sidekiq::ScheduledSet.new.map do |job|
      job.item.dig("args", 0, "arguments").first if job.item["wrapped"] == "SmsDeliveryJob"
    end.compact.to_set

    # Fetch relevant notifications
    notifs = Notification.joins(appointment: :slot)
                         .where('slots.date > ?', Date.today)
                         .where(appointments: { state: 'booked' })
                         .where(state: 'programmed')

    # Hash to track rescheduled jobs per day
    rescheduled_jobs_count = Hash.new(0)

    notifs.each do |notif|
      next if scheduled_notification_ids.include?(notif.id)

      # Increment the counter for the slot's date
      rescheduled_jobs_count[notif.appointment.slot.date] += 1

      SmsDeliveryJob.set(wait_until: notif.delivery_time)
                    .perform_later(notif.id)
    end

    puts rescheduled_jobs_count
  end
end