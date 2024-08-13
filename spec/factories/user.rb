FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name { 'Doe' }
    sequence(:email) { |n| "john#{n}@doe.fr" }
    role { 'cpip' }

    password { '1mot2passeSecurise!' }
    password_confirmation { '1mot2passeSecurise!' }

    security_charter_accepted_at { Time.zone.now - 2.minutes }

    trait :in_organization do
      transient do
        type { 'spip' }
        interressort { false }
      end
      after(:build) do |user, evaluator|
        user.organization = FactoryBot.create(:organization, organization_type: evaluator.type,
                                                             use_inter_ressort: evaluator.interressort)
      end
    end

    factory :user_with_appointments do
      after(:create) do |user|
        create_list(:appointment, 3, user:)
      end
    end
  end
end
