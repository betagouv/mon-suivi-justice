# == Schema Information
#
# Table name: agendas
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  place_id   :bigint
#
# Indexes
#
#  index_agendas_on_place_id  (place_id)
#
# Foreign Keys
#
#  fk_rails_...  (place_id => places.id)
#
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
