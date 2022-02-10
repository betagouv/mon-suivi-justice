class Slot < ApplicationRecord
  has_paper_trail

  belongs_to :agenda
  belongs_to :slot_type, optional: true
  belongs_to :appointment_type
  has_many :appointments, dependent: :destroy

  validates :date, :starting_time, :duration, :capacity, presence: true
  validates_inclusion_of :available, in: [true, false]
  validate :workday?

  scope :relevant_and_available, lambda { |agenda, appointment_type|
    where(
      agenda_id: agenda.id,
      appointment_type_id: appointment_type.id,
      available: true
    )
  }

  scope :future, -> { where('date >= ?', Date.today) }
  scope :available, -> { where(available: true) }

  scope :in_department, lambda { |department|
    joins(agenda: { place: { organization: :areas_organizations_mappings } })
      .where(areas_organizations_mappings: { area: department })
  }

  scope :in_organization, lambda { |organization|
    joins(agenda: :place).where(agendas: { places: { organization: organization } })
  }

  scope :with_appointment_type_with_slot_system, lambda {
    joins(:appointment_type).merge(AppointmentType.with_slot_types)
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

  private

  def workday?
    return unless date.blank? || date.saturday? || date.sunday? || Holidays.on(date, :fr).any?

    errors.add(:date, I18n.t('activerecord.errors.models.slot.attributes.date.not_workday'))
  end
end
