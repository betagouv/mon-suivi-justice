require 'rails_helper'

RSpec.describe AppointmentType, type: :model do
  it { should validate_presence_of(:name) }

  it { should have_many(:notification_types) }
  it { should have_many(:slot_types).dependent(:destroy) }

  it { should have_many(:places).through(:place_appointment_types) }
end
