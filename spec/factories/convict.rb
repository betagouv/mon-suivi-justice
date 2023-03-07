FactoryBot.define do
  factory :convict do
    first_name { 'Jane' }
    last_name { 'Doe' }
    sequence(:phone, 2) { |n| "060606060#{n}" }
    no_phone { false }

    factory :convict_with_organizations do
      transient do
        org_count { 1 }
      end

      organizations do
        Array.new(org_count) { association(:organization) }
      end
    end
  
  end
end
