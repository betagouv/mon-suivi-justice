class CreateUsersUserAlerts < ActiveRecord::Migration[7.0]
  def change
    create_table :user_alerts_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :user_alert, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_alerts_users, [:user_id, :user_alert_id], unique: true
  end
end
