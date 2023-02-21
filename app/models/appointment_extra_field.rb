class AppointmentExtraField < ApplicationRecord
  belongs_to :appointment
  belongs_to :extra_field
  validates :value, presence: true

  accepts_nested_attributes_for :extra_field
end
