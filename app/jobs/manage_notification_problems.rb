class ManageNotificationProblems < ApplicationJob
  queue_as :default

  def perform
    reschedule_unqueued_notifications
    inform_users_about_stucked_notifications
    inform_admins
  end

  private

  def reschedule_unqueued_notifications
    notifications_to_reschedule.each do |notif|
      SmsDeliveryJob.set(wait_until: notif.delivery_time)
                    .perform_later(notif.id)
    end
  end

  def inform_users_about_stucked_notifications
    stucked_notifications.each(&:failed_programmed!)
  end

  def inform_admins
    return unless notifications_to_reschedule.any? || stucked_notifications.any?

    AdminMailer.notifications_problems(notifications_to_reschedule.pluck(:id), stucked_notifications.pluck(:id))
               .deliver_later
  end

  def notifications_to_reschedule
    @notifications_to_reschedule ||= sms_notifications_to_be_send.where.not(id: scheduled_sms_delivery_jobs_notif_ids)
  end

  def stucked_notifications
    @stucked_notifications ||=
      Notification.joins(appointment: :slot)
                  .where('slots.date < ?', Time.zone.now - 1.hour)
                  .where(state: 'programmed', role: 'reminder')
  end

  def scheduled_sms_delivery_jobs_notif_ids
    @scheduled_sms_delivery_jobs_notif_ids ||=
      Sidekiq::ScheduledSet.new.map do |job|
        job.item.dig('args', 0, 'arguments', 0) if job.item['wrapped'] == 'SmsDeliveryJob'
      end.compact
  end

  def sms_notifications_to_be_send
    reminder_notifications_to_be_send.or(other_notifications_to_be_send).or(mistakenly_marked_as_sent_notifications)
  end

  def reminder_notifications_to_be_send
    Notification.joins(appointment: :slot)
                .where('slots.date > ?', Time.zone.now + 4.hours)
                .where(appointments: { state: 'booked' })
                .where(state: 'programmed', role: 'reminder')
  end

  def other_notifications_to_be_send
    Notification.where(state: 'programmed', role: %w[summon cancelation no_show reschedule])
  end

  def mistakenly_marked_as_sent_notifications
    Notification.joins(appointment: :slot)
                .where(state: 'sent', external_id: nil, updated_at: Time.zone.now - 2.days..)
  end
end
