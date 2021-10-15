FactoryBot.define do
  factory :jurisdiction do
    sequence(:name) { |seq| "jurisdiction_name_#{seq}" }
  end
end
