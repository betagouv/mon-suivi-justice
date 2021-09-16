require 'rails_helper'

RSpec.describe SlotType, type: :model do
  it { should belong_to(:appointment_type) }
  it { should belong_to(:agenda) }
  it { should validate_presence_of(:week_day) }
  it { should validate_presence_of(:starting_time) }
  it { should validate_presence_of(:duration) }
  it { should validate_presence_of(:capacity) }

  it { should define_enum_for(:week_day).with_values(%i[monday tuesday wednesday thursday friday]) }
end
