class AddDiscardedAtToAppointmentTypes < ActiveRecord::Migration[7.1]
  def change
    add_column :appointment_types, :discarded_at, :datetime
    add_index :appointment_types, :discarded_at
  end
end
