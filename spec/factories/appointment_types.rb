FactoryBot.define do
  factory :appointment_type do
    name { 'premier contact' }

    transient do
      organization { nil }
    end

    trait :with_notification_types do
      after(:create) do |apt_type, evaluator|
        create(:notification_type, appointment_type: apt_type, organization: evaluator.organization, role: :summon)
        create(:notification_type, appointment_type: apt_type, organization: evaluator.organization, role: :reminder)
        create(:notification_type, appointment_type: apt_type, organization: evaluator.organization, role: :cancelation)
        create(:notification_type, appointment_type: apt_type, organization: evaluator.organization, role: :no_show)
        create(:notification_type, appointment_type: apt_type, organization: evaluator.organization, role: :reschedule)
      end
    end
  end
end
