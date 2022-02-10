class SlotType < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  belongs_to :agenda
  has_many :slots, dependent: :nullify

  validates :starting_time,
            uniqueness: { scope: %i[agenda_id appointment_type_id week_day],
                          message: I18n.t('activerecord.errors.models.slot_type.multiple_uniqueness') }

  # When a SlotType is destroyed, we remove corresponding slots, as they are no more available
  # Slot already booked are preserved.

  before_destroy :destroy_dependent_slots_not_booked, prepend: true

  validates :week_day, :duration, :starting_time, :capacity, presence: true
  enum week_day: %i[monday tuesday wednesday thursday friday]

  private

  def destroy_dependent_slots_not_booked
    slots.where.not(id: Appointment.select(:slot_id)).destroy_all
  end
end
