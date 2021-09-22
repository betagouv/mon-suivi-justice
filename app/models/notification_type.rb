class NotificationType < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  validates :template, presence: true

  enum role: %i[summon reminder cancelation no_show]
  enum reminder_period: %i[one_day two_days]
end
