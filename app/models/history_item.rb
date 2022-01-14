class HistoryItem < ApplicationRecord
  belongs_to :convict
  belongs_to :appointment, optional: true

  validates :content, presence: true

  attr_readonly :content

  enum category: %i[appointment notification convict]

  enum event: {
    book_appointment: 0,
    cancel_appointment: 1,
    fulfil_appointment: 2,
    miss_appointment: 4,
    excuse_appointment: 5,
    reschedule_appointment: 6,
    send_now_summon_notification: 7,
    send_then_reminder_notification: 8,
    cancel_reminder_notification: 9,
    dir_greff_sap: 10,
    send_now_cancelation_notification: 11,
    send_now_no_show_notification: 12,
    send_now_reschedule_notification: 13,
    archive_convict: 14,
    unarchive_convict: 15
  }

  def self.validate_event(event)
    HistoryItem.events.keys.include?(event.to_s)
  end
end
