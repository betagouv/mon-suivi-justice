# == Schema Information
#
# Table name: notification_types
#
#  id                  :bigint           not null, primary key
#  reminder_period     :integer          default("one_day")
#  role                :integer          default("summon")
#  template            :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  appointment_type_id :bigint
#
# Indexes
#
#  index_notification_types_on_appointment_type_id  (appointment_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (appointment_type_id => appointment_types.id)
#
require 'rails_helper'

RSpec.describe NotificationType, type: :model do
  it { should belong_to(:appointment_type) }
  it { should validate_presence_of(:template) }

  it { should define_enum_for(:role).with_values(%i[summon reminder cancelation no_show reschedule]) }
  it { should define_enum_for(:reminder_period).with_values(%i[one_day two_days]) }
end
