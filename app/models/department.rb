class Department < ApplicationRecord
  has_many :areas_organizations_mappings, dependent: :destroy, as: :area
  has_many :organizations, through: :areas_organizations_mappings, source: :organization
  has_many :areas_convicts_mappings, dependent: :destroy, as: :area
  has_many :convicts, through: :areas_convicts_mappings, source: :convict

  validates :name, uniqueness: true, presence: true, inclusion: { in: FRENCH_DEPARTMENTS.map(&:name) }
  validates :number, uniqueness: true, presence: true, inclusion: { in: FRENCH_DEPARTMENTS.map(&:number) }

  def tribunal
    organizations.where(organization_type: 'tj').first
  end
end
