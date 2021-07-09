class Agenda < ApplicationRecord
  belongs_to :place
  has_many :slots, dependent: :destroy

  validates :name, presence: true
end
