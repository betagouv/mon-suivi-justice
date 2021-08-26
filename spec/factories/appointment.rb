FactoryBot.define do
  factory :appointment do
    appointment_type
    convict
    slot
    state { 'created' }
  end

  trait :with_notifications do
    after(:create) do |apt|
      create(:notification, appointment: apt, role: :summon)
      create(:notification, appointment: apt, role: :reminder)
      create(:notification, appointment: apt, role: :cancelation)
    end
  end
end
