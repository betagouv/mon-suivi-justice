class Headquarter < ApplicationRecord
  has_many :organizations
  has_many :users
  validates :name, presence: true
end
