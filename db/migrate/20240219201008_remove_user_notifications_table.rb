class RemoveUserNotificationsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :user_notifications
  end
end
