class RemoveAppointmentTypeIdFromAppointment < ActiveRecord::Migration[6.1]
  def change
    remove_column :appointments, :appointment_type_id
  end
end
