FactoryBot.define do
  factory :organization do
    sequence(:name) { |seq| "organization_#{seq}" }
  end
end
