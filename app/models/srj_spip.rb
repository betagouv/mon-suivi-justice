class SrjSpip < ApplicationRecord
  belongs_to :organization, optional: true
  has_many :cities
end
