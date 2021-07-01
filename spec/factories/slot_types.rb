FactoryBot.define do
  factory :slot_type do
    appointment_type
    week_day { :monday }
    starting_time { Time.new }
    duration { 60 }
    capacity { 3 }
  end
end
