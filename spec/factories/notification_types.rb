FactoryBot.define do
  factory :notification_type do
    appointment_type
    role { :summon }
    template { 'test' }

    trait :reminder do
      role { :reminder }
    end

    trait :two_days do
      reminder_period { :two_days }
    end
  end
end
