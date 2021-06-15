require 'rails_helper'

RSpec.describe Appointment, type: :model do
  subject { FactoryBot.build(:appointment) }

  it { should belong_to(:convict) }
  it { should belong_to(:slot) }
  it { should belong_to(:appointment_type) }

  describe 'State machine' do
    it { is_expected.to have_states :waiting, :booked }

    it { is_expected.to transition_from :waiting, to_state: :booked, on_event: :book }
  end
end
