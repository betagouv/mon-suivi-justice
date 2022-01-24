# == Schema Information
#
# Table name: organizations
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_on_name  (name) UNIQUE
#
class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :places, dependent: :destroy
  has_many :areas_organizations_mappings, dependent: :destroy
  has_many :departments,  through: :areas_organizations_mappings, source: :area, source_type: 'Department'
  has_many :jurisdictions, through: :areas_organizations_mappings, source: :area, source_type: 'Jurisdiction'

  validates :name, presence: true, uniqueness: true

  has_rich_text :jap_modal_content
end
