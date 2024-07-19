class ManageNotificationProblems < ApplicationJob
  queue_as :default

  def perform
    reschedule_unqueued_notifications
    inform_users_about_failed_notifications
    inform_admins
  end

  private

  def reschedule_unqueued_notifications
    notifications_to_reschedule.each do |notif|
      SmsDeliveryJob.set(wait_until: notif.delivery_time)
                    .perform_later(notif.id)
    end
  end

  def inform_users_about_failed_notifications
    notifications_to_be_marked_as_failed.each(&:mark_as_failed!)
  end

  def inform_admins
    return unless notifications_to_reschedule.any? || notifications_to_be_marked_as_failed.any?

    AdminMailer.notifications_problems(notifications_to_reschedule.pluck(:id),
                                       notifications_to_be_marked_as_failed.pluck(:id))
               .deliver_later
  end

  def notifications_to_reschedule
    @notifications_to_reschedule ||= sms_notifications_to_be_send.where.not(id: scheduled_sms_delivery_jobs_notif_ids)
  end

  def notifications_to_be_marked_as_failed
    @notifications_to_be_marked_as_failed ||=
      high_failure_notifications.or(stucked_notifications)
  end

  def high_failure_notifications
    @high_failure_notifications ||=
      Notification.joins(appointment: :slot).where(state: %w[created programmed], failed_count: 5..)
  end

  def stucked_notifications
    @stucked_notifications ||=
      Notification.joins(appointment: :slot)
                  .where('slots.date < ?', 1.hour.ago)
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
                .where.not(failed_count: 5..)
                .where('slots.date > ?', 4.hours.from_now)
                .where(appointments: { state: 'booked' })
                .where(state: 'programmed', role: 'reminder')
  end

  def other_notifications_to_be_send
    Notification.where.not(failed_count: 5..).where(state: 'programmed',
                                                    role: %w[summon
                                                             cancelation no_show reschedule])
  end

  def mistakenly_marked_as_sent_notifications
    Notification.joins(appointment: :slot)
                .where.not(failed_count: 5..)
                .where(state: 'sent', external_id: nil, updated_at: 2.days.ago..)
  end
end
