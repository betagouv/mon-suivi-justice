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
require 'rails_helper'

RSpec.describe HistoryItem, type: :model do
  it { should belong_to(:convict) }
  it { should belong_to(:appointment).optional(true) }

  it { should validate_presence_of(:content) }
  it { should define_enum_for(:category).with_values(%i[appointment notification convict]) }

  it {
    should define_enum_for(:event).with_values(
      {
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
    )
  }
end
