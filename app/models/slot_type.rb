class SlotType < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  belongs_to :agenda

  has_many :slots, dependent: :nullify

  #
  # When a SlotType is destroyed, we remove corresponding slots, as they are no more available
  # Slot already booked are preserved.
  #
  before_destroy :destroy_slots_not_booked # TODO: spec

  validates :week_day, :duration, :starting_time, :capacity, presence: true
  enum week_day: %i[monday tuesday wednesday thursday friday]

  private

  def destroy_slots_not_booked
    slots.where.not(id: Appointment.select(:slot_id)).destroy_all
  end
end
