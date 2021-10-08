FactoryBot.define do
  factory :areas_organizations_mapping do
    association :area, factory: :department
    organization
  end
end
