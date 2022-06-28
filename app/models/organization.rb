class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :places, dependent: :destroy
  has_many :areas_organizations_mappings, dependent: :destroy
  has_many :departments,  through: :areas_organizations_mappings, source: :area, source_type: 'Department'
  has_many :jurisdictions, through: :areas_organizations_mappings, source: :area, source_type: 'Jurisdiction'

  enum organization_type: { spip: 0, tj: 1 }
  validates :organization_type, presence: true

  validates :name, presence: true, uniqueness: true

  has_rich_text :jap_modal_content

  def ten_next_days_with_slots(appointment_type)
    Slot.future
        .in_organization(self)
        .where(appointment_type: appointment_type)
        .pluck(:date)
        .uniq
        .sort
        .first(10)
  end

  def first_day_with_slots(appointment_type)
    ten_next_days_with_slots(appointment_type).first
  end
end
