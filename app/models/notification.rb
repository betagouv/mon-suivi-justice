class Notification < ApplicationRecord
  belongs_to :appointment_type

  validates :name, :content, presence: true
end
