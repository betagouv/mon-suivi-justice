FactoryBot.define do
  factory :notification do
    appointment
    template { 'test' }
    content { 'test' }
    state { 'created' }
    role { 'summon' }
  end
end
