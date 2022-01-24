# == Schema Information
#
# Table name: appointment_types
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :appointment_type do
    name { 'premier contact' }
  end

  trait :with_notification_types do
    after(:create) do |apt_type|
      create(:notification_type, appointment_type: apt_type, role: :summon)
      create(:notification_type, appointment_type: apt_type, role: :reminder)
      create(:notification_type, appointment_type: apt_type, role: :cancelation)
      create(:notification_type, appointment_type: apt_type, role: :no_show)
      create(:notification_type, appointment_type: apt_type, role: :reschedule)
    end
  end
end
