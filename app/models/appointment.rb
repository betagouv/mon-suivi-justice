class Appointment < ApplicationRecord
  belongs_to :convict
  belongs_to :place

  validates :date, presence: true
end
