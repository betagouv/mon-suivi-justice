class Slot < ApplicationRecord
  has_paper_trail

  belongs_to :agenda
  belongs_to :slot_type, optional: true
  belongs_to :appointment_type
  has_many :appointments, dependent: :destroy

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

  def full?
    used_capacity == capacity
  end
end
