class Slot < ApplicationRecord
  has_paper_trail

  belongs_to :place
  belongs_to :appointment_type

  validates :date, :starting_time, :duration, :capacity, presence: true
  validates_inclusion_of :available, in: [true, false]

  scope :relevant_and_available, (lambda do |place, appointment_type|
    where(
      place_id: place.id,
      appointment_type_id: appointment_type.id,
      available: true
    )
  end)

  scope :future, -> { where('date >= ?', Date.today) }
end
