FactoryBot.define do
  factory :slot do
    date { Date.today.beginning_of_week + 8.day }
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
