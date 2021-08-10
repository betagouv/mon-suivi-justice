require 'rails_helper'

RSpec.describe Appointment, type: :model do
  subject { build(:appointment) }

  it { should belong_to(:convict) }
  it { should belong_to(:slot) }
  it { should belong_to(:appointment_type) }

  it { should define_enum_for(:origin_department).with_values(%i[bex gref_co pr]) }

  describe 'state machine' do
    before do
      allow(subject).to receive(:summon_notif)
                    .and_return(create(:notification))
      allow(subject).to receive(:reminder_notif)
                    .and_return(create(:notification))
    end

    it { is_expected.to have_states :waiting, :booked, :canceled }

    it { is_expected.to transition_from :waiting, to_state: :booked, on_event: :book }
    it { is_expected.to transition_from :booked, to_state: :canceled, on_event: :cancel }
  end
end
