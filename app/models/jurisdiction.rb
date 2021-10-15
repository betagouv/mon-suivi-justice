class Jurisdiction < ApplicationRecord
  has_many :areas_organizations_mappings, dependent: :destroy, as: :area
  has_many :organizations, through: :areas_organizations_mappings, source: :area, source_type: 'Jurisdiction'

  validates :name, uniqueness: true, presence: true
end
