class NotificationType < ApplicationRecord
  belongs_to :appointment_type
  validates :template, presence: true

  enum role: %i[summon reminder]
  enum reminder_period: %i[one_day two_days]
end
