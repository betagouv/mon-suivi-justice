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
        dir_greff_sap: 10,
        send_now_cancelation_notification: 11,
        send_now_no_show_notification: 12,
        send_now_reschedule_notification: 13,
        archive_convict: 14,
        unarchive_convict: 15
      }
    )
  }
end
