FactoryBot.define do
  factory :place do
    name { 'Spip du 92' }
    adress { 'fake adress' }
    phone { '0606060606' }
    place_type { :spip }
  end
end
