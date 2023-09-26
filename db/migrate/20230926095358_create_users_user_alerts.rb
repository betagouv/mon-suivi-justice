class CreateUsersUserAlerts < ActiveRecord::Migration[7.0]
  def change
    create_table :users_user_alerts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :user_alert, null: false, foreign_key: true

      t.timestamps
    end

    add_index :users_user_alerts, [:user_id, :user_alert_id], unique: true
  end
end
