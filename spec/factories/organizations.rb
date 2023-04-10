FactoryBot.define do
  factory :organization do
    organization_type { 'spip' }
    sequence(:name) { |seq| "organization_#{seq}" }
    time_zone { 'Europe/Paris' }

    trait :with_department do
      after(:create) do |organization|
        department = Department.all.first || FactoryBot.create(:department)
        create :areas_organizations_mapping, organization: organization, area: department
      end
    end
  end
end
