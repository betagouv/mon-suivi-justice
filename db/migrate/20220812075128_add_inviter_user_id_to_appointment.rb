class AddInviterUserIdToAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :inviter_user_id, :bigint
  end
end
