class ManageUnsendNotification < ApplicationJob
  queue_as :default

  def perform
    reschedule_unqueued_notifications
    inform_users_about_unsend_notifications
    inform_admins
  end

  private

  def reschedule_unqueued_notifications
    notifications_to_reschedule.each do |notif|
      SmsDeliveryJob.set(wait_until: notif.delivery_time)
                    .perform_later(notif.id)
    end
  end

  def inform_users_about_unsend_notifications
    unsend_notifications.each(&:failed_programmed!)
  end

  def inform_admins
    AdminMailer.notifications_problems(notifications_to_reschedule.pluck(:id), unsend_notifications.pluck(:id))
               .deliver_later
  end

  def notifications_to_reschedule
    @notifications_to_reschedule ||= sms_notifications_to_be_send.where.not(id: scheduled_sms_delivery_jobs_notif_ids)
  end

  def unsend_notifications
    @unsend_notifications ||=
      Notification.joins(appointment: :slot)
                  .where('slots.date < ?', Time.zone.now - 1.day)
                  .where(state: 'programmed', role: 'reminder')
  end

  def scheduled_sms_delivery_jobs_notif_ids
    @scheduled_sms_delivery_jobs_notif_ids ||=
      Sidekiq::ScheduledSet.new.map do |job|
        job.item.dig('args', 0, 'arguments', 0) if job.item['wrapped'] == 'SmsDeliveryJob'
      end.compact
  end

  def sms_notifications_to_be_send
    Notification.joins(appointment: :slot)
                .where('slots.date > ?', Time.zone.now + 1.day)
                .where(appointments: { state: 'booked' })
                .where(state: 'programmed', role: 'reminder')
  end
end
