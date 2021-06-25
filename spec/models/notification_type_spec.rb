require 'rails_helper'

RSpec.describe NotificationType, type: :model do
  it { should belong_to(:appointment_type) }
  it { should validate_presence_of(:template) }

  it { should define_enum_for(:role).with_values(%i[summon reminder]) }
  it { should define_enum_for(:reminder_period).with_values(%i[one_day two_days]) }
end
