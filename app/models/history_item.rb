class HistoryItem < ApplicationRecord
  belongs_to :convict
  belongs_to :appointment

  enum category: %i[appointment notification]

  enum event: %i[
    book_appointment
    cancel_appointment
    fulfil_appointment
    miss_appointment
    send_now_summon_notification
    receive_summon_notification
    failed_send_summon_notification
    send_then_reminder_notification
    receive_reminder_notification
    cancel_reminder_notification
    failed_send_reminder_notification
    send_now_cancelation_notification
    receive_cancelation_notification
    failed_send_cancelation_notification
  ]

  def self.validate_event(event)
    HistoryItem.events.keys.include?(event.to_s)
  end
end
