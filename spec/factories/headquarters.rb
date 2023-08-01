FactoryBot.define do
  factory :headquarter do
    sequence(:name) { |n| "Headquarter #{n}" }
  end
end
