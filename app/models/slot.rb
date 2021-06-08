class Slot < ApplicationRecord
  belongs_to :place

  validates :date, :starting_time, presence: true
end
