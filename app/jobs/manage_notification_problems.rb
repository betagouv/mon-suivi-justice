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
      notif.role == 'reminder' ? notif.program! : notif.program_now!
    end
  end

  def inform_users_about_failed_notifications
    notifications_to_be_marked_as_failed.each(&:handle_unsent!)
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
      high_failure_notifications.or(stucked_no_show_notifications).or(other_stucked_notifications)
  end

  def high_failure_notifications
    @high_failure_notifications ||=
      Notification.joins(appointment: :slot).where(state: %w[created programmed], failed_count: 5..)
  end

  def stucked_no_show_notifications
    @stucked_no_show_notifications ||=
      Notification.appointment_more_than_1_month_ago
                  .where(state: 'programmed', role: 'no_show')
  end

  def other_stucked_notifications
    @other_stucked_notifications ||=
      Notification.appointment_in_the_past
                  .where(state: 'programmed', role: %w[reminder summon cancelation reschedule])
  end

  def scheduled_sms_delivery_jobs_notif_ids
    @scheduled_sms_delivery_jobs_notif_ids ||=
      Sidekiq::ScheduledSet.new.map do |job|
        job.item.dig('args', 0, 'arguments', 0) if job.item['wrapped'] == 'SmsDeliveryJob'
      end.compact
  end

  def sms_notifications_to_be_send
    cancelation_notifications_to_be_send.or(no_show_notifications_to_be_send).or(other_notifications_to_be_send)
  end

  def cancelation_notifications_to_be_send
    Notification.retryable
                .appointment_in_more_than_4_hours
                .where(appointments: { state: 'canceled' })
                .where(state: 'programmed', role: 'cancelation')
  end

  def no_show_notifications_to_be_send
    Notification.retryable
                .appointment_recently_past
                .where(appointments: { state: 'no_show' })
                .where(state: 'programmed', role: 'no_show')
  end

  def other_notifications_to_be_send
    Notification.retryable
                .appointment_in_more_than_4_hours
                .where(appointments: { state: 'booked' })
                .where(state: 'programmed', role: %w[summon reminder reschedule])
  end
end
