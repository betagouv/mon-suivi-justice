FactoryBot.define do
  factory :notification_type do
    appointment_type
    organization
    role { :summon }
    template { 'test' }
    reminder_period { :two_days }
    is_default { false }
  end
end
