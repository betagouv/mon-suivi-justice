FactoryBot.define do
  factory :slot do
    date { Date.today.next_occurring(:monday) }
    starting_time { Time.new }
    available { true }
    duration { 60 }
    capacity { 3 }
    used_capacity { 0 }
    slot_type
    appointment_type
    agenda

    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
