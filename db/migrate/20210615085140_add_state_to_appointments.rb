class AddStateToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :state, :string
  end
end
