class AppointmentType < ApplicationRecord
  has_many :notification_types

  validates :name, presence: true
end
