# == Schema Information
#
# Table name: jurisdictions
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jurisdictions_on_name  (name) UNIQUE
#
class Jurisdiction < ApplicationRecord
  has_many :areas_organizations_mappings, dependent: :destroy, as: :area
  has_many :organizations, through: :areas_organizations_mappings, source: :area, source_type: 'Jurisdiction'
  has_many :areas_convicts_mappings, dependent: :destroy, as: :area
  has_many :convicts, through: :areas_convicts_mappings, source: :area, source_type: 'Jurisdiction'

  validates :name, uniqueness: true, presence: true
end
