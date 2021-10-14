class Juridiction < ApplicationRecord
  has_many :areas_organizations_mappings, dependent: :destroy, as: :area
  has_many :organizations, through: :areas_organizations_mappings, source: :area, source_type: 'Juridiction'
  has_many :areas_convicts_mappings, dependent: :destroy, as: :area
  has_many :convicts, through: :areas_convicts_mappings, source: :area, source_type: 'Juridiction'

  validates :name, uniqueness: true, presence: true
end
