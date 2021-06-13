class Appointment < ApplicationRecord
  belongs_to :appointment_type
  belongs_to :convict
  belongs_to :slot
end
