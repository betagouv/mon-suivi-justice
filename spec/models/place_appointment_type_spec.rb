require 'rails_helper'

RSpec.describe PlaceAppointmentType, type: :model do
  it { should belong_to(:place) }
  it { should belong_to(:appointment_type) }
end
