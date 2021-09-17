class SlotType < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  belongs_to :agenda

  has_many :slots, dependent: :nullify

  #
  # When a SlotType is destroyed, we remove corresponding slots, as they are no more available
  # Slot already booked are preserved.
  #
  before_destroy :destroy_orphan_slots_not_booked, prepend: true

  validates :week_day, :duration, :starting_time, :capacity, presence: true
  enum week_day: %i[monday tuesday wednesday thursday friday]

  private

  def destroy_orphan_slots_not_booked
    # TODO: a revoir, jsute ceux de ce slot_type
    Slot.where(slot_type_id: nil).where.not(id: Appointment.select(:slot_id)).destroy_all
  end
end
