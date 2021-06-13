class AppointmentType < ApplicationRecord
  has_many :notifications

  validates :name, presence: true
end
