require 'rails_helper'

RSpec.describe HistoryItem, type: :model do
  it { should belong_to(:convict) }
  it { should belong_to(:appointment).optional(true) }

  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:event) }
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
        program_now_summon_notification: 7,
        mark_as_sent_reminder_notification: 8,
        cancel_reminder_notification: 9,
        program_now_cancelation_notification: 10,
        program_now_no_show_notification: 11,
        program_now_reschedule_notification: 12,
        archive_convict: 13,
        unarchive_convict: 14,
        update_phone_convict: 15,
        add_phone_convict: 16,
        remove_phone_convict: 17,
        failed_programmed_reminder_notification: 18,
        accept_divestment: 19,
        refuse_divestment: 20
      }
    )
  }
end
