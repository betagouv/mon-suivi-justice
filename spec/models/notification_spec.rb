require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { should belong_to(:appointment_type) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:content) }

  # it { should define_enum_for(:type).with_values(%i[sms email]) }
end
