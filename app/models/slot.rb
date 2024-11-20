class Slot < ApplicationRecord
  include TransfertValidator

  has_paper_trail

  belongs_to :agenda
  belongs_to :slot_type, optional: true
  belongs_to :appointment_type
  has_many :appointments, dependent: :destroy

  validates :date, :starting_time, :duration, :capacity, presence: true
  validates :used_capacity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :capacity, numericality: { greater_than: 0 }
  validates :capacity, numericality: { greater_than_or_equal_to: :used_capacity }

  validates_inclusion_of :available, in: [true, false]
  validate :workday?
  validate :coherent_organization_type?

  delegate :place, to: :agenda
  delegate :name, :adress, :display_phone, :contact_detail, :preparation_link, to: :place, prefix: true
  delegate :organization, to: :place

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
  scope :not_full, -> { where(full: false) }

  scope :in_organization, lambda { |organization|
    joins(agenda: :place).where(agendas: { places: { organization: } })
  }

  scope :in_jurisdiction, lambda { |user_organization|
    joins(agenda: :place).where(agendas: {
                                  places: { organization: [user_organization, *user_organization.linked_organizations] }
                                })
  }

  scope :with_appointment_type_with_slot_system, lambda {
    joins(:appointment_type).merge(AppointmentType.with_slot_types)
  }

  scope :available_or_with_appointments, lambda { |date, appointment_type|
    where(date:, appointment_type:)
      # we use LEFT JOIN to get slots with or without appointments
      .joins('LEFT JOIN appointments ON appointments.slot_id = slots.id')
      .where('slots.available = true OR (appointments.id IS NOT NULL AND appointments.state != ?)', 'canceled')
  }

  def self.ransackable_attributes(_auth_object = nil)
    %w[full agenda_id appointment_type_id date starting_time]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[agenda appointment_type]
  end

  def all_capacity_used?
    used_capacity == capacity
  end

  def datetime
    Time.new(date.year, date.month, date.day, localized_time.hour, localized_time.min, localized_time.sec)
  end

  def localized_time
    @localized_time ||= TZInfo::Timezone.get(place.organization.time_zone).to_local(starting_time)
  end

  def civil_date
    I18n.l(date, format: :civil)
  end

  def real_capacity
    return capacity if available?

    appointments.active.count
  end

  private

  def workday?
    return false if appointment_type&.allowed_on_weekends?
    return false unless date.blank? || date.saturday? || date.sunday? || Holidays.on(date, :fr).any?

    errors.add(:date, I18n.t('activerecord.errors.models.slot.attributes.date.not_workday'))
  end

  def coherent_organization_type?
    return false unless appointment_type&.sortie_audience?
    return false if check_organization_type(appointment_type)

    errors.add(:appointment_type,
               I18n.t('activerecord.errors.models.slot.attributes.appointment_type.wrong_organization'))
  end

  def check_organization_type(appointment_type)
    case appointment_type.name
    when "Sortie d'audience SAP"
      return true if place.organization.tj?
    when "Sortie d'audience SPIP"
      return true if place.organization.spip?
    when 'SAP DDSE'
      return true
    end

    false
  end

  def add_transfert_error(transfert, attribute, place_name)
    errors.add(:base,
               I18n.t("activerecord.errors.models.slot.attributes.date.#{attribute}", date: transfert.date.to_fs,
                                                                                      place_name:))
  end
end
