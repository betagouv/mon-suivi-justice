FactoryBot.define do
  factory :appointment do
    date { '01/01/2021' }
    convict
    place
  end
end
