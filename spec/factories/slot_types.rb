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
