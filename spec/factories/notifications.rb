# == Schema Information
#
# Table name: notifications
#
#  id              :bigint           not null, primary key
#  content         :text
#  reminder_period :integer          default("one_day")
#  role            :integer          default("summon")
#  state           :string
#  template        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  appointment_id  :bigint           not null
#  external_id     :string
#
# Indexes
#
#  index_notifications_on_appointment_id  (appointment_id)
#
# Foreign Keys
#
#  fk_rails_...  (appointment_id => appointments.id)
#
FactoryBot.define do
  factory :notification do
    appointment
    template { 'test' }
    content { 'test' }
    state { 'created' }
    role { 'summon' }
  end
end
