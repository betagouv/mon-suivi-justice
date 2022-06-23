class AddUserToAppointment < ActiveRecord::Migration[6.1]
  def change
    add_reference :appointments, :user, null: true, foreign_key: true
  end
end
