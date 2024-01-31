class OrganizationDivestment < ApplicationRecord
  belongs_to :organization
  belongs_to :divestment

  validates :comment, length: { maximum: 120 }, allow_blank: true
end
