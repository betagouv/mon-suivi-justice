FactoryBot.define do
  factory :notification do
    name { 'test' }
    template { 'test' }
    content { 'test' }
    appointment
  end
end
