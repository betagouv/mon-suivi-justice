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
FactoryBot.define do
  factory :notification_type do
    appointment_type
    role { :summon }
    template { 'test' }
    reminder_period { :two_days }
  end
end
