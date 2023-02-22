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
  # limit should be 3, but we need to add one more to be able to delete and add an extra_field at the same time
  abymize :extra_fields, permit: :all_attributes, limit: 4, allow_destroy: true
  has_one :tj
  has_one :spip
  has_one :linked_organization, class_name: 'Organization'

  has_many :convicts_organizations_mappings
  has_many :convicts, through: :convicts_organizations_mappings

  enum organization_type: { spip: 0, tj: 1 }

  validates :organization_type, presence: true
  validates :name, presence: true, uniqueness: true
  validate :linked_organization_type

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

  private

  def linked_organization_type
    if organization_type == 'spip' && linked_organization.present? && linked_organization.organization_type != 'tj'
      errors.add(:linked_organization, 'must be a TJ')
    elsif organization_type == 'tj' && linked_organization.present? && linked_organization.organization_type != 'spip'
      errors.add(:linked_organization, 'must be a SPIP')
    end
  end
end
