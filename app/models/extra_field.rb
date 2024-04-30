class ExtraField < ApplicationRecord
  DATA_TYPES = { text: 'texte', date: 'date' }.freeze
  SCOPES = { appointment_create: 'appointment_create', appointment_update: 'appointment_update' }.freeze

  belongs_to :organization
  has_many :appointments, through: :appointment_extra_fields
  has_many :appointment_extra_fields, inverse_of: :extra_field, dependent: :destroy
  has_and_belongs_to_many :appointment_types
  accepts_nested_attributes_for :appointment_extra_fields, reject_if: :all_blank, allow_destroy: true

  enum data_type: DATA_TYPES
  enum scope: SCOPES
  validates :name, presence: true
  validates :data_type, presence: true
  validates :scope, presence: true
  validates :appointment_types, presence: true
  validate :organization_is_tj

  scope :related_to_sap, -> { joins(:appointment_types).where(appointment_types: { name: "Sortie d'audience SAP" }) }
  scope :related_to_spip, -> { joins(:appointment_types).where(appointment_types: { name: "Sortie d'audience SPIP" }) }

  def appointment_extra_fields_for_appointment(appointment_id)
    appointment_extra_fields.find { |aef| aef.appointment_id == appointment_id } if appointment_id.present?
  end

  def find_places_with_shared_appointment_types
    # Determine the organization and linked organizations
    linked_organizations = organization.linked_organizations
    organization_ids = [organization_id, *linked_organizations.map(&:id)]

    # Query for places that are associated with the primary organization
    # or any of the linked organizations and that share the ExtraField's appointment types
    Place.joins(:appointment_types)
         .where(organization_id: organization_ids)
         .where(appointment_types: { id: appointment_type_ids })
         .distinct
  end

  def relate_to_sap?
    appointment_types.any?(&:sortie_audience_sap?)
  end

  def relate_to_spip?
    appointment_types.any?(&:sortie_audience_spip?)
  end

  private

  def organization_is_tj
    errors.add(:organization, 'doit être un TJ') unless organization.tj?
  end
end
