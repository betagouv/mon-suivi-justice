class Appointment < ApplicationRecord
  belongs_to :appointment_type
  belongs_to :convict
  belongs_to :slot

  attr_accessor :place_id
end
