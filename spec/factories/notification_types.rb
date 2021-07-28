FactoryBot.define do
  factory :notification_type do
    appointment_type
    role { :summon }
    template { 'test' }
    reminder_period { :two_days }
  end
end
