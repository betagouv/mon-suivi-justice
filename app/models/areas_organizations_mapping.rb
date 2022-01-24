# == Schema Information
#
# Table name: areas_organizations_mappings
#
#  id              :bigint           not null, primary key
#  area_type       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  area_id         :bigint
#  organization_id :bigint
#
# Indexes
#
#  index_areas_organizations_mappings_on_area                   (area_type,area_id)
#  index_areas_organizations_mappings_on_organization_and_area  (organization_id,area_id,area_type) UNIQUE
#  index_areas_organizations_mappings_on_organization_id        (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class AreasOrganizationsMapping < ApplicationRecord
  belongs_to :organization
  belongs_to :area, polymorphic: true

  validates :area_type, inclusion: { in: %w[Department Jurisdiction] }
  validates :organization, uniqueness: { scope: :area }
end
