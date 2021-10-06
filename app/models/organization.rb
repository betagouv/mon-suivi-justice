class Organization < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :users, dependent: :destroy
  has_many :places, dependent: :destroy
end
