class Agenda < ApplicationRecord
  belongs_to :place
  has_many :slots, dependent: :destroy
  has_many :slot_types, dependent: :destroy
  has_many :appointment_types, through: :slot_type

  validates :name, presence: true
end
