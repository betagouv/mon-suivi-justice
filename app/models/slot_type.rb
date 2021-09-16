class SlotType < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  belongs_to :agenda

  validates :week_day, :duration, :starting_time, :capacity, presence: true
  enum week_day: %i[monday tuesday wednesday thursday friday]
end
