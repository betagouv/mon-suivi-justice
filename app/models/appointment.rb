class Appointment < ApplicationRecord
  belongs_to :convict
  validates :date, :slot, presence: true
end
