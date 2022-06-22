FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name { 'Doe' }
    sequence(:email) { |n| "john#{n}@doe.fr" }
    role { :admin }
    password { '1mot2passeSecurise!' }
    password_confirmation { '1mot2passeSecurise!' }
    association :organization, factory: %i[organization with_department]

    factory :user_with_appointments do
      after(:create) do |user|
        create_list(:appointment, 3, user: user)
      end
    end
  end
end
