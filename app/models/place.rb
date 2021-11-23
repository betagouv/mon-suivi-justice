class Place < ApplicationRecord
  include NormalizedPhone
  has_paper_trail

  validates :name, :adress, :phone, presence: true

  has_many :agendas, dependent: :destroy
  has_many :place_appointment_types
  has_many :appointment_types, through: :place_appointment_types
  belongs_to :organization

  accepts_nested_attributes_for :agendas, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :place_appointment_types

  scope :in_organization, ->(organization) { where(organization: organization) }

  scope :in_department, ->(department) { joins(:organization).where(organization: { area: department }) }
end
