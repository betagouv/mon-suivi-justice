class Organization < ApplicationRecord
  include Abyme::Model

  has_many :users, dependent: :destroy
  has_many :places, dependent: :destroy
  has_many :notification_types, dependent: :destroy
  has_many :areas_organizations_mappings, dependent: :destroy
  has_many :departments, through: :areas_organizations_mappings, source: :area, source_type: 'Department'
  has_many :jurisdictions, through: :areas_organizations_mappings, source: :area, source_type: 'Jurisdiction'
  has_many :created_appointments, class_name: 'Appointment', foreign_key: 'creating_organization'
  has_many :extra_fields, dependent: :destroy, inverse_of: :organization
  belongs_to :headquarter, optional: true
  abymize :extra_fields, permit: :all_attributes, allow_destroy: true
  has_many :agendas, through: :places, dependent: :nullify
  has_one :tj
  has_one :spip
  has_one :associated_organization, class_name: 'Organization',
                                    foreign_key: 'linked_organization_id', inverse_of: :linked_organization

  belongs_to :linked_organization, class_name: 'Organization', optional: true, inverse_of: :associated_organization

  has_many :convicts_organizations_mappings
  has_many :convicts, through: :convicts_organizations_mappings

  enum organization_type: { spip: 0, tj: 1 }

  validates :organization_type, presence: true
  validates :name, presence: true, uniqueness: true
  validate :extra_fields_count

  has_rich_text :jap_modal_content

  def ten_next_days_with_slots(appointment_type)
    Slot.future
        .in_organization(self)
        .where(appointment_type: appointment_type)
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
        new_notif_type = default.where(role: role).first.dup
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

    jurisdictions.first&.organizations&.select(&:tj?)&.first
  end

  def spips
    return [] unless tj?

    jurisdictions.first&.organizations&.select(&:spip?)
  end

  private

  # rubocop:disable Metrics/MethodLength
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
  # rubocop:enable Metrics/MethodLength
end
