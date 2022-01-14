require 'rails_helper'

RSpec.describe HistoryItem, type: :model do
  it { should belong_to(:convict) }
  it { should belong_to(:appointment).optional(true) }

  it { should validate_presence_of(:content) }
  it { should define_enum_for(:category).with_values(%i[appointment notification convict]) }

  it do
    should define_enum_for(:event).with_values(
      %i[
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
        send_now_reschedule_notification
        archive_convict
        unarchive_convict
      ]
    )
  end
end
