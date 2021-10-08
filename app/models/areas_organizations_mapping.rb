class AreasOrganizationsMapping < ApplicationRecord
  belongs_to :organization
  belongs_to :area, polymorphic: true

  validates :area_type, inclusion: { in: ['Department'] }
  validates :organization, uniqueness: { scope: :area }
end
