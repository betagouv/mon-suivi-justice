FactoryBot.define do
  factory :convict do
    first_name { 'Jane' }
    last_name { 'Doe' }
    sequence(:phone, 2) { |n| "060606060#{n.to_s}" }
  end
end
