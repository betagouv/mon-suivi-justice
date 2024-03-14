class OrganizationDivestment < ApplicationRecord
  belongs_to :organization
  belongs_to :divestment

  enum state: { pending: 'pending', auto_accepted: 'auto_accepted', accepted: 'accepted',
                refused: 'refused', ignored: 'ignored' }

  validates :comment, length: { maximum: 120 }, allow_blank: true
end
