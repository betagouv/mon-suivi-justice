FactoryBot.define do
  factory :appointment do
    appointment_type
    convict
    slot
    state { 'created' }
  end
end
