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
  has_many :extra_fields, dependent: :destroy, inverse_of: :organization
  belongs_to :headquarter, optional: true
  abymize :extra_fields, permit: :all_attributes, allow_destroy: true
  has_many :agendas, through: :places

  has_and_belongs_to_many :spips, class_name: 'Organization', foreign_key: 'tj_id', join_table: 'spips_tjs',
                                  association_foreign_key: 'spip_id', optional: true
  has_and_belongs_to_many :tjs, class_name: 'Organization', foreign_key: 'spip_id', join_table: 'spips_tjs',
                                association_foreign_key: 'tj_id', optional: true

  has_many :convicts_organizations_mappings, dependent: :destroy
  has_many :convicts, through: :convicts_organizations_mappings

  enum organization_type: { spip: 0, tj: 1 }

  validates :organization_type, presence: true
  validates :name, presence: true, uniqueness: true
  validate :extra_fields_count
  validate :spips_tjs_type

  has_rich_text :jap_modal_content

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

  def after_hearing_available_appointment_types
    places.map(&:appointment_type_with_slot_types).flatten.uniq
  end

  private

  def extra_fields_count
    return if extra_fields.count <= 3

    grouped_extra_fields = {
      spip: extra_fields.count(&:relate_to_spip?),
      sap: extra_fields.count(&:relate_to_sap?)
    }

    if grouped_extra_fields[:spip] > 3
      errors.add(:extra_fields,
                 I18n.t('activerecord.errors.models.organization.attributes.extra_fields.too_many.spip'))
    end

    return unless grouped_extra_fields[:sap] > 3

    errors.add(:extra_fields,
               I18n.t('activerecord.errors.models.organization.attributes.extra_fields.too_many.sap'))
  end

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
