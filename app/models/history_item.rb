class HistoryItem < ApplicationRecord
  belongs_to :convict
  belongs_to :appointment

  enum category: %i[appointment notification]

  enum event: %i[
    book_appointment
    cancel_appointment
    fulfil_appointment
    miss_appointment
    excuse_appointment
    reschedule_appointment
    send_now_summon_notification
    send_then_reminder_notification
    cancel_reminder_notification
    send_now_cancelation_notification
    send_now_no_show_notification
  ]

  def self.validate_event(event)
    HistoryItem.events.keys.include?(event.to_s)
  end

  def notification_role
    return 'reschedule_notif' if reschedule_appointment?

    array = event.delete_suffix('_notification').split('_')
    array -= array.shift(2)

    "#{array.join('_')}_notif"
  end
end
