class Department < ApplicationRecord
  has_many :areas_organizations_mappings, dependent: :destroy, as: :area
  has_many :organizations, through: :areas_organizations_mappings, source: :area, source_type: 'Department'

  validates :name, uniqueness: true, presence: true, inclusion:   { in: FRENCH_DEPARTMENTS.map(&:name) }
  validates :number, uniqueness: true, presence: true, inclusion: { in: FRENCH_DEPARTMENTS.map(&:number) }
end
