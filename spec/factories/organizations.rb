FactoryBot.define do
  factory :organization do
    organization_type { 'spip' }
    sequence(:name) { |seq| "organization_#{seq}" }
    time_zone { 'Europe/Paris' }
    tjs { [] }
    spips { [] }
  end
end
