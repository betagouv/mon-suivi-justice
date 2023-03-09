class ExtraField < ApplicationRecord
  DATA_TYPES = { text: 'texte', date: 'date' }.freeze
  SCOPES = { appointment_create: 'appointment_create', appointment_update: 'appointment_update' }.freeze

  belongs_to :organization
  has_many :appointments, through: :appointment_extra_fields
  has_many :appointment_extra_fields, inverse_of: :extra_field, dependent: :destroy
  has_and_belongs_to_many :appointment_types, dependent: :destroy
  accepts_nested_attributes_for :appointment_extra_fields, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :appointment_types, reject_if: :all_blank, allow_destroy: true

  enum data_type: DATA_TYPES
  enum scope: SCOPES
  validates :name, presence: true
  validates :data_type, presence: true

  def appointment_extra_fields_for_appointment(appointment_id)
    appointment_extra_fields.find { |aef| aef.appointment_id == appointment_id } if appointment_id.present?
  end
end
