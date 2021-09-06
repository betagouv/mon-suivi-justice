require 'rails_helper'

RSpec.describe HistoryItem, type: :model do
  it { should belong_to(:convict) }
  it { should belong_to(:appointment) }

  it { should define_enum_for(:category).with_values(%i[appointment notification]) }

  it do
    should define_enum_for(:event).with_values(
      %i[
        book_appointment
        cancel_appointment
        fulfil_appointment
        miss_appointment
        send_now_summon_notification
        send_then_reminder_notification
        cancel_reminder_notification
        send_now_cancelation_notification
      ]
    )
  end
end
