FactoryBot.define do
  factory :convict do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::Base.numerify('+3361#######') }
    no_phone { false }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    organizations { [create(:organization)] }
    appi_uuid { "2024#{Faker::Number.number(digits: 16)}"}
  end
end
