# == Schema Information
#
# Table name: slots
#
#  id                  :bigint           not null, primary key
#  available           :boolean          default(TRUE)
#  capacity            :integer          default(1)
#  date                :date
#  duration            :integer          default(30)
#  starting_time       :time
#  used_capacity       :integer          default(0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  agenda_id           :bigint           not null
#  appointment_type_id :bigint           not null
#  slot_type_id        :bigint
#
# Indexes
#
#  index_slots_on_agenda_id            (agenda_id)
#  index_slots_on_appointment_type_id  (appointment_type_id)
#  index_slots_on_slot_type_id         (slot_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (agenda_id => agendas.id)
#  fk_rails_...  (appointment_type_id => appointment_types.id)
#  fk_rails_...  (slot_type_id => slot_types.id)
#
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
  scope :available, -> { where(available: true) }

  scope :in_department, lambda { |department|
    joins(agenda: { place: { organization: :areas_organizations_mappings } })
      .where(areas_organizations_mappings: { area: department })
  }

  scope :in_organization, lambda { |organization|
    joins(agenda: :place).where(agendas: { places: { organization: organization } })
  }

  def full?
    used_capacity == capacity
  end

  def self.batch_close(agenda_id:, appointment_type_id:, data:)
    data.each do |day|
      Slot.where(
        agenda_id: agenda_id,
        appointment_type_id: appointment_type_id,
        date: day[:date],
        starting_time: day[:starting_times]
      ).update_all(available: false)
    end
  end
end
