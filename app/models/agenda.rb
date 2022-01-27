class Agenda < ApplicationRecord
  belongs_to :place
  has_many :slots, dependent: :destroy
  has_many :slot_types, dependent: :destroy

  validates :name, presence: true

  delegate :appointment_type_with_slot_types, to: :place

  scope :in_organization, ->(organization) { joins(:place).where(place: { organization: organization }) }

  scope :in_department, lambda { |department|
    joins(place: { organization: :areas_organizations_mappings })
      .where(areas_organizations_mappings: { area: department })
  }

  def appointment_type_with_slot_types?
    appointment_type_with_slot_types.length.positive?
  end
end
