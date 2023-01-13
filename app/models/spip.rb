class Spip < ApplicationRecord
  belongs_to :organization, optional: true
end
