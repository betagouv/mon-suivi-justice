FactoryBot.define do
  factory :appointment do
    convict
    slot
    state { 'created' }
  end

  trait :with_notifications do
    after(:create) do |apt|
      create(:notification, appointment: apt, role: :summon)
      create(:notification, appointment: apt, role: :reminder)
      create(:notification, appointment: apt, role: :cancelation)
      create(:notification, appointment: apt, role: :no_show)
    end
  end

  trait :skip_validate do
    to_create { |instance| instance.save(validate: false) }
  end
end
