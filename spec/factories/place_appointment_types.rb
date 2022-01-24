# == Schema Information
#
# Table name: place_appointment_types
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  appointment_type_id :bigint
#  place_id            :bigint
#
# Indexes
#
#  index_place_appointment_types_on_appointment_type_id  (appointment_type_id)
#  index_place_appointment_types_on_place_id             (place_id)
#
FactoryBot.define do
  factory :place_appointment_type do
    place
    appointment_type
  end
end
