class Organization < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :users, dependent: :destroy
  has_many :places, dependent: :destroy
  has_many :areas_organizations_mappings, dependent: :destroy
  has_many :departments,  through: :areas_organizations_mappings, source: :area, source_type: 'Department'
  has_many :jurisdictions, through: :areas_organizations_mappings, source: :area, source_type: 'Jurisdiction'
end
