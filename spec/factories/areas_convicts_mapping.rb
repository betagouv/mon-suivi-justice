FactoryBot.define do
  factory :areas_convicts_mapping do
    association :area, factory: :department
    convict
  end
end
