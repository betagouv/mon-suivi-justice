FactoryBot.define do
  factory :notification do
    name { 'test' }
    content { 'test' }
    appointment
  end
end
