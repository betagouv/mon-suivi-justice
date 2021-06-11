class RemovePlaceFromAppointment < ActiveRecord::Migration[6.1]
  def change
    remove_reference :appointments, :place, null: false, foreign_key: true
    add_reference :appointments, :slot, null: false, foreign_key: true
  end
end
