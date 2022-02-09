class Place < ApplicationRecord
  include NormalizedPhone
  has_paper_trail

  validates :name, :adress, :main_contact_method, presence: true
  validates :phone, presence: true, if: :phone_main_contact_method?
  validates :contact_email, presence: true, if: :email_main_contact_method?
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :preparation_link, presence: true

  has_many :agendas, dependent: :destroy
  has_many :place_appointment_types, dependent: :destroy
  has_many :appointment_types, through: :place_appointment_types
  belongs_to :organization

  enum main_contact_method: {
    phone: 0,
    email: 1
  }, _default: :phone, _suffix: true

  accepts_nested_attributes_for :agendas, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :place_appointment_types

  scope :in_organization, ->(organization) { where(organization: organization) }

  scope :in_department, lambda { |department|
    joins(organization: :areas_organizations_mappings)
      .where(areas_organizations_mappings: { area_type: 'Department', area_id: department.id })
  }

  def appointment_type_with_slot_types
    appointment_types.with_slot_types
  end

  def contact_detail
    phone_main_contact_method? ? display_phone(spaces: false) : contact_email
  end
end
