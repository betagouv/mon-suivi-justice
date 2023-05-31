class Slot < ApplicationRecord
  has_paper_trail

  belongs_to :agenda
  belongs_to :slot_type, optional: true
  belongs_to :appointment_type
  has_many :appointments, dependent: :destroy

  validates :date, :starting_time, :duration, :capacity, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validates :capacity, numericality: { greater_than_or_equal_to: :used_capacity }

  validates_inclusion_of :available, in: [true, false]
  validate :workday?
  validate :coherent_organization_type?

  delegate :place, to: :agenda
  delegate :name, :adress, :display_phone, :contact_detail, :preparation_link, to: :place, prefix: true
  validate :handle_transfert, on: %i[create update]

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

  scope :in_departments, lambda { |departments|
    ids = departments.map(&:id)
    joins(agenda: { place: { organization: :areas_organizations_mappings } })
      .where(areas_organizations_mappings: { area_type: 'Department', area_id: ids })
  }

  scope :in_organization, lambda { |organization|
    joins(agenda: :place).where(agendas: { places: { organization: organization } })
  }

  scope :in_jurisdiction, lambda { |user_organization|
    joins(agenda: :place).where(agendas: {
                                  places: { organization: [user_organization, *user_organization.linked_organizations] }
                                })
  }

  scope :with_appointment_type_with_slot_system, lambda {
    joins(:appointment_type).merge(AppointmentType.with_slot_types)
  }

  def all_capacity_used?
    used_capacity == capacity
  end

  def localized_time
    time_zone = TZInfo::Timezone.get(place.organization.time_zone)
    time_zone.to_local(starting_time)
  end

  private

  def workday?
    return if appointment_type&.allowed_on_weekends?
    return unless date.blank? || date.saturday? || date.sunday? || Holidays.on(date, :fr).any?

    errors.add(:date, I18n.t('activerecord.errors.models.slot.attributes.date.not_workday'))
  end

  def coherent_organization_type?
    return unless appointment_type&.sortie_audience?
    return if check_organization_type(appointment_type)

    errors.add(:appointment_type,
               I18n.t('activerecord.errors.models.slot.attributes.appointment_type.wrong_organization'))
  end

  def check_organization_type(appointment_type)
    case appointment_type.name
    when "Sortie d'audience SAP"
      return true if agenda.place.organization.organization_type == 'tj'
    when "Sortie d'audience SPIP"
      return true if agenda.place.organization.organization_type == 'spip'
    when 'SAP DDSE'
      return true
    end

    false
  end

  def handle_transfert
    if place.transfert_in && date < place.transfert_in.date
      errors.add(:base,
                 I18n.t('activerecord.errors.models.appointment.attributes.date.transfert_in',
                        date: place.transfert_in.date))
    elsif place.transfert_out && date > place.transfert_out.date
      errors.add(:base,
                 I18n.t('activerecord.errors.models.appointment.attributes.date.transfert_out',
                        date: place.transfert_out.date))
    end
  end
end
