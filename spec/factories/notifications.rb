FactoryBot.define do
  factory :notification do
    template { 'test' }
    content { 'test' }
    appointment
  end
end
