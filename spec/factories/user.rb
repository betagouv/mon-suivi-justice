FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name { 'Doe' }
    sequence(:email) { |n| "john#{n}@doe.fr" }
    role { :admin }
    password { '1mot2passeSecurise!' }
    password_confirmation { '1mot2passeSecurise!' }
    organization
  end
end
