class Agenda < ApplicationRecord
  belongs_to :place
  has_many :slots, dependent: :destroy
  has_many :slot_types, dependent: :destroy

  validates :name, presence: true

  scope :in_organization, ->(organization) { joins(:place).where(place: { organization: organization }) }

  scope :in_department, lambda { |department|
    joins(place: { organization: :areas_organizations_mappings })
      .where(areas_organizations_mappings: { area: department })
  }

  def appointment_type_with_slot_types?
    AppointmentType.where(id: slot_types.pluck(:appointment_type_id))
                   .map(&:with_slot_types?).include?(true)
  end
end
