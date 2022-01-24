# == Schema Information
#
# Table name: appointment_types
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe AppointmentType, type: :model do
  it { should validate_presence_of(:name) }

  it { should have_many(:notification_types) }
  it { should have_many(:slot_types).dependent(:destroy) }

  it { should have_many(:places).through(:place_appointment_types) }

  describe '#no_show_notif' do
    it 'returns nil without any no_show notification_types' do
      appointment_type = build :appointment_type
      expect(appointment_type.no_show_notif).to be nil
    end

    it 'returns the no_show notification_types' do
      appointment_type = build :appointment_type
      no_show_notif = create :notification_type, role: :no_show, appointment_type: appointment_type
      expect(appointment_type.no_show_notif).to eq no_show_notif
    end
  end
end
