class RemoveSlotFromAppointments < ActiveRecord::Migration[6.1]
  def change
    remove_column :appointments, :slot
  end
end
