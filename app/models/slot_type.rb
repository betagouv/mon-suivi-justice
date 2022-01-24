# == Schema Information
#
# Table name: slot_types
#
#  id                  :bigint           not null, primary key
#  capacity            :integer          default(1)
#  duration            :integer          default(30)
#  starting_time       :time
#  week_day            :integer          default("monday")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  agenda_id           :bigint
#  appointment_type_id :bigint
#
# Indexes
#
#  index_slot_types_on_agenda_id            (agenda_id)
#  index_slot_types_on_appointment_type_id  (appointment_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (agenda_id => agendas.id)
#  fk_rails_...  (appointment_type_id => appointment_types.id)
#
class SlotType < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  belongs_to :agenda

  has_many :slots, dependent: :nullify

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
