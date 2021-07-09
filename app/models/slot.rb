class Slot < ApplicationRecord
  has_paper_trail

  belongs_to :agenda
  belongs_to :appointment_type
  has_one :appointment, dependent: :destroy

  validates :date, :starting_time, :duration, :capacity, presence: true
  validates_inclusion_of :available, in: [true, false]

  scope :relevant_and_available, (lambda do |agenda, appointment_type|
    where(
      agenda_id: agenda.id,
      appointment_type_id: appointment_type.id,
      available: true
    )
  end)

  scope :future, -> { where('date >= ?', Date.today) }
end
