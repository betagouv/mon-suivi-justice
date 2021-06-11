class Appointment < ApplicationRecord
  belongs_to :convict
  belongs_to :slot
end
