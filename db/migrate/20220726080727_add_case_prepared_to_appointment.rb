class AddCasePreparedToAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :case_prepared, :boolean, default: false, null: false
  end
end
