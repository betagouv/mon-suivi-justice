class RemoveAppointmentTypeFromNotification < ActiveRecord::Migration[6.1]
  def change
    remove_reference :notifications, :appointment_type, null: false, foreign_key: true
    add_reference :notifications, :appointment, null: false, foreign_key: true
  end
end
