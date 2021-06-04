class Place < ApplicationRecord
  validates :name, :adress, presence: true
end
