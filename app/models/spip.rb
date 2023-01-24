class Spip < ApplicationRecord
  belongs_to :organization, optional: true
  has_one :city
end
