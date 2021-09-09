require 'rails_helper'

RSpec.describe AppointmentType, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:place_type) }

  it { should have_many(:notification_types) }
  it { should have_many(:slot_types) }

  it { should define_enum_for(:place_type).with_values(%i[spip sap]) }

  describe '#missed_notif' do
    it 'returns nil without any missed notification_types' do
      appointment_type = create :appointment_type
      expect(appointment_type.missed_notif).to be nil
    end
    it 'returns the missed notification_types' do
      appointment_type = create :appointment_type
      missed_notif = create :notification_type, role: :missed, appointment_type: appointment_type
      expect(appointment_type.missed_notif).to eq missed_notif
    end
  end
end
