require 'rails_helper'

RSpec.describe HistoryItem, type: :model do
  it { should belong_to(:convict) }
  it { should belong_to(:appointment) }

  it do
    should define_enum_for(:event).with_values(
      %i[
        book_appointment
        cancel_appointment
        fulfil_appointment
        miss_appointment
      ]
    )
  end
end
