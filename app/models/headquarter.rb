class Headquarter < ApplicationRecord
  has_many :organizations, dependent: :nullify
  has_many :users, dependent: :nullify
  validates :name, presence: true
end
