FactoryBot.define do
  factory :appointment_type do
    name { 'premier contact' }
  end

  trait :with_notification_types do
    after(:create) do |apt_type|
      create(:notification_type, appointment_type: apt_type, role: :summon)
      create(:notification_type, appointment_type: apt_type, role: :reminder)
      create(:notification_type, appointment_type: apt_type, role: :cancelation)
    end
  end
end
