class Jurisdiction < ApplicationRecord
  has_many :areas_organizations_mappings, dependent: :destroy, as: :area
  has_many :organizations, through: :areas_organizations_mappings
  has_many :areas_convicts_mappings, dependent: :destroy, as: :area
  has_many :convicts, through: :areas_convicts_mappings

  validates :name, uniqueness: true, presence: true
end
