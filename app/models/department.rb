# == Schema Information
#
# Table name: departments
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  number     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_departments_on_name    (name) UNIQUE
#  index_departments_on_number  (number) UNIQUE
#
class Department < ApplicationRecord
  has_many :areas_organizations_mappings, dependent: :destroy, as: :area
  has_many :organizations, through: :areas_organizations_mappings, source: :area, source_type: 'Department'
  has_many :areas_convicts_mappings, dependent: :destroy, as: :area
  has_many :convicts, through: :areas_convicts_mappings, source: :area, source_type: 'Department'

  validates :name, uniqueness: true, presence: true, inclusion:   { in: FRENCH_DEPARTMENTS.map(&:name) }
  validates :number, uniqueness: true, presence: true, inclusion: { in: FRENCH_DEPARTMENTS.map(&:number) }
end
