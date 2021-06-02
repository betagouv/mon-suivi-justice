FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name { 'Doe' }
    sequence(:email) { |n| "john#{n}@doe.fr" }
    role { :admin }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
