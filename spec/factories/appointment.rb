FactoryBot.define do
  factory :appointment do
    date { '01/01/2021' }
    appointment_type
    convict
    slot
  end
end
