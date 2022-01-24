# == Schema Information
#
# Table name: notification_types
#
#  id                  :bigint           not null, primary key
#  reminder_period     :integer          default("one_day")
#  role                :integer          default("summon")
#  template            :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  appointment_type_id :bigint
#
# Indexes
#
#  index_notification_types_on_appointment_type_id  (appointment_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (appointment_type_id => appointment_types.id)
#
class NotificationType < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  validates :template, presence: true

  enum role: %i[summon reminder cancelation no_show reschedule]
  enum reminder_period: %i[one_day two_days]
end
