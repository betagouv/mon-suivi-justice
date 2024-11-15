FactoryBot.define do
  factory :notification do
    appointment
    template { 'test' }
    content { 'test' }
    state { 'created' }
    role { 'summon' }
    failed_count { 0 }
    target_phone { '+33611111111' }
    response_code { '0' }
  end
end
