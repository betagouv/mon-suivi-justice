class PlaceAppointmentType < ApplicationRecord
  belongs_to :place
  belongs_to :appointment_type
end
