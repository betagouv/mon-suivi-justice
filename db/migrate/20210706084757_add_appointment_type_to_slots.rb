class AddAppointmentTypeToSlots < ActiveRecord::Migration[6.1]
  def change
    add_reference :slots, :appointment_type, null: false, foreign_key: true
  end
end
