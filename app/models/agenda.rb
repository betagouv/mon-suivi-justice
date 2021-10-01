class Agenda < ApplicationRecord
  belongs_to :place
  has_many :slots, dependent: :destroy
  has_many :slot_types, dependent: :destroy
  has_many :appointment_types, through: :slot_type

  validates :name, presence: true

  scope :in_organization, -> (organization) { joins(:place).where(place: {organization: organization}) }
end
