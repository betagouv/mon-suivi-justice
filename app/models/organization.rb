class Organization < ApplicationRecord
  include Abyme::Model
  has_many :users, dependent: :destroy
  has_many :places, dependent: :destroy
  has_many :notification_types, dependent: :destroy
  has_many :areas_organizations_mappings, dependent: :destroy
  has_many :departments, through: :areas_organizations_mappings, source: :area, source_type: 'Department'
  has_many :jurisdictions, through: :areas_organizations_mappings, source: :area, source_type: 'Jurisdiction'
  has_many :created_appointments, class_name: 'Appointment', foreign_key: 'creating_organization_id',
                                  dependent: :nullify
  has_many :created_convicts, class_name: 'Convict', foreign_key: 'creating_organization_id', dependent: :nullify
  has_many :extra_fields, dependent: :destroy
  belongs_to :headquarter, optional: true
  abymize :extra_fields, permit: :all_attributes, allow_destroy: true
  has_many :agendas, through: :places
  has_many :appointments, through: :places

  has_and_belongs_to_many :spips, class_name: 'Organization', foreign_key: 'tj_id', join_table: 'spips_tjs',
                                  association_foreign_key: 'spip_id', optional: true
  has_and_belongs_to_many :tjs, class_name: 'Organization', foreign_key: 'spip_id', join_table: 'spips_tjs',
                                association_foreign_key: 'tj_id', optional: true

  has_many :convicts_organizations_mappings, dependent: :destroy
  has_many :convicts, through: :convicts_organizations_mappings

  # dessaisissements initiés
  has_many :divestments

  # demandes de dessaisissements reçues
  has_many :organization_divestments

  enum organization_type: { spip: 0, tj: 1 }

  validates :organization_type, presence: true
  validates :name, presence: true, uniqueness: true
  validate :extra_fields_count
  validate :spips_tjs_type

  delegate :local_admin, to: :users
  alias local_admins local_admin

  has_rich_text :jap_modal_content

  scope :with_divestment_reminders_due, lambda {
    joins(:organization_divestments)
      .merge(OrganizationDivestment.reminders_due)
      .distinct
  }

  scope :with_ignored_divestment, lambda {
    joins(organization_divestments: :divestment)
      .where(organization_divestments: { state: :ignored })
      .where(divestments: { state: :pending })
      .distinct
  }

  def ten_next_days_with_slots(appointment_type)
    Slot.future
        .in_organization(self)
        .where(appointment_type:)
        .pluck(:date)
        .uniq
        .sort
        .first(20)
  end

  def first_day_with_slots(appointment_type)
    ten_next_days_with_slots(appointment_type).first
  end

  def extra_fields_for_agenda
    if tj?
      extra_fields
    else
      tj&.extra_fields
    end
  end

  def setup_notification_types
    all_default = NotificationType.default

    AppointmentType.all.each do |apt_type|
      default = all_default.where(appointment_type: apt_type)

      NotificationType.roles.each_key do |role|
        new_notif_type = default.where(role:).first.dup
        new_notif_type.assign_attributes(is_default: false, still_default: true)
        new_notif_type.organization = self
        new_notif_type.save!
      end
    end
  end

  def appointment_added_field_labels
    appointment_added_fields.map { |field| field['name'] }
  end

  def tj
    return nil unless spip?

    # In most cases spip will only have 1 associated tj
    # we use this to avoid to handle the case where a spip has multiple tjs for optionnal fields
    tjs.first
  end

  def linked_organizations
    return tjs if organization_type == 'spip'
    return spips if organization_type == 'tj'

    []
  end

  def number_of_convicts
    convicts.count
  end

  def custom_template?(appointment_type: nil, role: nil)
    filtered_notification_types = notification_types.where(still_default: false)
    filtered_notification_types = filtered_notification_types.where(appointment_type:) if appointment_type
    filtered_notification_types = filtered_notification_types.where(role:) if role
    filtered_notification_types.any?
  end

  def after_hearing_available_appointment_types
    places.map(&:appointment_type_with_slot_types).flatten.uniq
  end

  def too_many_appointments_without_status?
    appointments_last_3_months = Appointment.in_organization(self).where('slots.date >= ? AND slots.date < ?',
                                                                         3.months.ago, Date.today)
    total_appointments = appointments_last_3_months.count

    return false if total_appointments.zero?

    past_booked_appointments = appointments_last_3_months.where(state: 'booked').count

    (past_booked_appointments * 100.fdiv(total_appointments)).round > 20
  end

  def all_local_admins
    return headquarter.local_admins if headquarter.present?

    local_admins
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def extra_fields_count
    return if extra_fields.size <= 4

    if extra_fields.reject(&:marked_for_destruction?).count(&:relate_to_spip?) > 4
      errors.add(:extra_fields,
                 I18n.t('activerecord.errors.models.organization.attributes.extra_fields.too_many.spip'))
    end

    return unless extra_fields.reject(&:marked_for_destruction?).count(&:relate_to_sap?) > 4

    errors.add(:extra_fields,
               I18n.t('activerecord.errors.models.organization.attributes.extra_fields.too_many.sap'))
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def spips_tjs_type
    if organization_type == 'tj' && tjs&.present?
      errors.add(:tjs, 'cannot be set for a TJ')
    elsif organization_type == 'spip' && spips&.present?
      errors.add(:spips, 'cannot be set for a SPIP')
    end
    if tjs.any? { |tj| tj.organization_type != 'tj' }
      errors.add(:tjs, 'must be a TJ')
    elsif spips.any? { |spip| spip.organization_type != 'spip' }
      errors.add(:spips, 'must be a SPIP')
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
end
