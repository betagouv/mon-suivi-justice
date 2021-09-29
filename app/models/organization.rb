class Organization < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :users, dependent: :destroy
  has_many :places, dependent: :destroy
end
