FactoryBot.define do
  factory :convict do
    first_name { 'Jane' }
    last_name { 'Doe' }
    sequence(:phone, 2) { |n| "060606060#{n}" }
    no_phone { false }
    date_of_birth { '1990-01-01' }
    organizations { [create(:organization)] }
  end
end
