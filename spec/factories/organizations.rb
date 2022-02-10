FactoryBot.define do
  factory :organization do
    sequence(:name) { |seq| "organization_#{seq}" }

    trait :with_department do
      after(:create) do |organization|
        department = Department.all.first || FactoryBot.create(:department)
        create :areas_organizations_mapping, organization: organization, area: department
      end
    end
  end
end
