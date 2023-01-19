FactoryBot.define do
  factory :appointment_extra_field do
    appointment { "" }
    extra_field { "" }
    value { "MyString" }
  end
end
