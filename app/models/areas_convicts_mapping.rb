# == Schema Information
#
# Table name: areas_convicts_mappings
#
#  id         :bigint           not null, primary key
#  area_type  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  area_id    :bigint
#  convict_id :bigint
#
# Indexes
#
#  index_areas_convicts_mappings_on_area              (area_type,area_id)
#  index_areas_convicts_mappings_on_convict_and_area  (convict_id,area_id,area_type) UNIQUE
#  index_areas_convicts_mappings_on_convict_id        (convict_id)
#
# Foreign Keys
#
#  fk_rails_...  (convict_id => convicts.id)
#
class AreasConvictsMapping < ApplicationRecord
  belongs_to :convict
  belongs_to :area, polymorphic: true

  validates :area_type, inclusion: { in: %w[Department Jurisdiction] }
  validates :convict, uniqueness: { scope: :area }
end
