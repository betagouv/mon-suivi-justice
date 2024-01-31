FactoryBot.define do
  factory :divestment do
    convict
    organization
    user
    state { 'pending' }
  end
end
