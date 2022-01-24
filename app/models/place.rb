# == Schema Information
#
# Table name: places
#
#  id              :bigint           not null, primary key
#  adress          :string
#  name            :string
#  phone           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint
#
# Indexes
#
#  index_places_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class Place < ApplicationRecord
  include NormalizedPhone
  has_paper_trail

  validates :name, :adress, :phone, presence: true

  has_many :agendas, dependent: :destroy
  has_many :place_appointment_types, dependent: :destroy
  has_many :appointment_types, through: :place_appointment_types
  belongs_to :organization

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
end
