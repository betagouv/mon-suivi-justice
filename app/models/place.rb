class Place < ApplicationRecord
  include NormalizedPhone
  include Discard::Model
  has_paper_trail

  validates :name, :adress, :main_contact_method, presence: true
  validates :phone, presence: true, if: :phone_main_contact_method?
  validates :contact_email, presence: true, if: :email_main_contact_method?
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :preparation_link, presence: true

  has_many :agendas, dependent: :destroy
  has_many :place_appointment_types, dependent: :destroy
  has_many :appointment_types, through: :place_appointment_types
  has_many :appointments, through: :agendas
  has_one :transfert_in, dependent: :destroy, class_name: 'PlaceTransfert', foreign_key: :new_place_id
  has_one :transfert_out, dependent: :destroy, class_name: 'PlaceTransfert', foreign_key: :old_place_id
  has_one :old_location, dependent: :destroy, through: :transfert_in, source: :old_place
  has_one :new_location, dependent: :destroy, through: :transfert_out, source: :new_place
  belongs_to :organization

  enum main_contact_method: {
    phone: 0,
    email: 1
  }, _default: :phone, _suffix: true

  accepts_nested_attributes_for :agendas, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :place_appointment_types

  scope :in_organization, ->(organization) { where(organization: organization) }

  scope :in_jurisdiction, lambda { |user_organization|
    where(organization: [user_organization, *user_organization.linked_organizations])
  }

  scope :in_departments, lambda { |departments|
    ids = departments.map(&:id)
    joins(organization: :areas_organizations_mappings)
      .where(areas_organizations_mappings: { area_type: 'Department', area_id: ids })
  }

  scope :in_dep_spips, lambda { |departments|
    ids = departments.map(&:id)
    joins(organization: :areas_organizations_mappings)
      .where(areas_organizations_mappings: { area_type: 'Department', area_id: ids })
      .where(organizations: { organization_type: 'spip' })
  }

  def multiple_agendas?
    agendas.count > 1
  end

  def appointment_type_with_slot_types
    appointment_types.with_slot_types
  end

  def contact_detail
    phone_main_contact_method? ? display_phone(spaces: false) : contact_email
  end

  def transfert_out_date
    transfert_out&.date
  end

  def transfert_in_date
    transfert_in&.date
  end
end
