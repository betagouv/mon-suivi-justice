# == Schema Information
#
# Table name: slots
#
#  id                  :bigint           not null, primary key
#  available           :boolean          default(TRUE)
#  capacity            :integer          default(1)
#  date                :date
#  duration            :integer          default(30)
#  starting_time       :time
#  used_capacity       :integer          default(0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  agenda_id           :bigint           not null
#  appointment_type_id :bigint           not null
#  slot_type_id        :bigint
#
# Indexes
#
#  index_slots_on_agenda_id            (agenda_id)
#  index_slots_on_appointment_type_id  (appointment_type_id)
#  index_slots_on_slot_type_id         (slot_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (agenda_id => agendas.id)
#  fk_rails_...  (appointment_type_id => appointment_types.id)
#  fk_rails_...  (slot_type_id => slot_types.id)
#
FactoryBot.define do
  factory :slot do
    date { '01/01/2021' }
    starting_time { Time.new }
    available { true }
    duration { 60 }
    capacity { 3 }
    used_capacity { 0 }
    slot_type
    appointment_type
    agenda
  end
end
