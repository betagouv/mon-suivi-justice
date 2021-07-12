class AddAppointmentTypeToSlots < ActiveRecord::Migration[6.1]
  def change
    add_reference :slots, :appointment_type, foreign_key: true
  end
end
