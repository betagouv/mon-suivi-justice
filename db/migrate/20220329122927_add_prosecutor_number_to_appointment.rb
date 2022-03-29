class AddProsecutorNumberToAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :prosecutor_number, :string
  end
end
