# == Schema Information
#
# Table name: history_items
#
#  id             :bigint           not null, primary key
#  category       :integer          default("appointment")
#  content        :text
#  event          :integer          default("book_appointment")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  appointment_id :bigint
#  convict_id     :bigint
#
# Indexes
#
#  index_history_items_on_appointment_id  (appointment_id)
#  index_history_items_on_convict_id      (convict_id)
#
# Foreign Keys
#
#  fk_rails_...  (appointment_id => appointments.id)
#  fk_rails_...  (convict_id => convicts.id)
#
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
    send_now_cancelation_notification: 10,
    send_now_no_show_notification: 11,
    send_now_reschedule_notification: 12,
    archive_convict: 13,
    unarchive_convict: 14
  }

  def self.validate_event(event)
    HistoryItem.events.keys.include?(event.to_s)
  end
end
