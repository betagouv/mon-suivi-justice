class AreasConvictsMapping < ApplicationRecord
  belongs_to :convict
  belongs_to :area, polymorphic: true

  validates :area_type, inclusion: { in: %w[Department Juridiction] }
  validates :convict, uniqueness: { scope: :area }
end
