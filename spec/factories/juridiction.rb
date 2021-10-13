FactoryBot.define do
  factory :juridiction do
    sequence(:name) { |seq| "juridiction_name_#{seq}" }
  end
end
