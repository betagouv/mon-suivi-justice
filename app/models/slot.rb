class Slot < ApplicationRecord
  has_paper_trail

  belongs_to :agenda
  belongs_to :slot_type, optional: true
  belongs_to :appointment_type
  has_many :appointments, dependent: :destroy

  validates :date, :starting_time, :duration, :capacity, presence: true
  validates_inclusion_of :available, in: [true, false]
  validate :workday?
  validate :coherent_organization_type?

  delegate :place, to: :agenda
  delegate :name, :adress, :display_phone, :contact_detail, :preparation_link, to: :place, prefix: true

  scope :relevant_and_available, lambda { |agenda, appointment_type|
    where(
      agenda_id: agenda.id,
      appointment_type_id: appointment_type.id,
      available: true,
      full: false
    )
  }

  scope :relevant_and_available_all_agendas, lambda { |place, appointment_type|
    joins(:agenda).where(
      'agenda.place' => place,
      appointment_type_id: appointment_type.id,
      available: true,
      full: false
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

  def all_capacity_used?
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

  def coherent_organization_type?
    return unless appointment_type&.sortie_audience?

    case appointment_type.name
    when "Sortie d'audience SAP"
      return if agenda.place.organization.organization_type == 'sap'
    when "Sortie d'audience SPIP"
      return if agenda.place.organization.organization_type == 'spip'
    end

    errors.add(:appointment_type,
               I18n.t('activerecord.errors.models.slot.attributes.appointment_type.wrong_organization'))
  end
end
