class HistoryItem < ApplicationRecord
  belongs_to :convict
  belongs_to :appointment, optional: true

  validates :content, :event, presence: true

  attr_readonly :content

  enum category: %i[appointment notification convict]

  enum event: {
    book_appointment: 0,
    cancel_appointment: 1,
    fulfil_appointment: 2,
    miss_appointment: 4,
    excuse_appointment: 5,
    reschedule_appointment: 6,
    program_now_summon_notification: 7,
    send_then_reminder_notification: 8,
    cancel_reminder_notification: 9,
    program_now_cancelation_notification: 10,
    program_now_no_show_notification: 11,
    program_now_reschedule_notification: 12,
    archive_convict: 13,
    unarchive_convict: 14,
    update_phone_convict: 15,
    add_phone_convict: 16,
    remove_phone_convict: 17,
    failed_programmed_reminder_notification: 18
  }

  def self.validate_event(event)
    HistoryItem.events.keys.include?(event.to_s)
  end
end
