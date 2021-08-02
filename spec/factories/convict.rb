FactoryBot.define do
  factory :convict do
    title { :male }
    first_name { 'Jane' }
    last_name { 'Doe' }
    phone { '0606060606' }
    prosecutor_number { '302304' }
  end
end
