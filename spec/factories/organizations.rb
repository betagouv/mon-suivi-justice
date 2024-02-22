FactoryBot.define do
  factory :organization do
    organization_type { 'spip' }
    sequence(:name) { Faker::Fantasy::Tolkien.unique.location }
    time_zone { 'Europe/Paris' }
    tjs { [] }
    spips { [] }
  end
end
