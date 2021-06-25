FactoryBot.define do
  factory :notification_type do
    appointment_type
    role { :summon }
    template { 'test' }
  end
end
