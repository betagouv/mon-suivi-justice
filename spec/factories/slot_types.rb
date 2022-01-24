# == Schema Information
#
# Table name: slot_types
#
#  id                  :bigint           not null, primary key
#  capacity            :integer          default(1)
#  duration            :integer          default(30)
#  starting_time       :time
#  week_day            :integer          default("monday")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  agenda_id           :bigint
#  appointment_type_id :bigint
#
# Indexes
#
#  index_slot_types_on_agenda_id            (agenda_id)
#  index_slot_types_on_appointment_type_id  (appointment_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (agenda_id => agendas.id)
#  fk_rails_...  (appointment_type_id => appointment_types.id)
#
FactoryBot.define do
  factory :slot_type do
    appointment_type
    agenda
    week_day { :monday }
    starting_time { Time.new }
    duration { 60 }
    capacity { 3 }
  end
end
