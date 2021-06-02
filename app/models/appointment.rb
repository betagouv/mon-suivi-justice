class Appointment < ApplicationRecord
  belongs_to :convict
  validates :date, presence: true
end
