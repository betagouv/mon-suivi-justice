require 'rails_helper'

RSpec.describe AppointmentType, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:place_type) }

  it { should have_many(:notification_types) }
  it { should have_many(:slot_types) }

  it { should define_enum_for(:place_type).with_values(%i[spip sap]) }
end
