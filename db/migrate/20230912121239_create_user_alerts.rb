class CreateUserAlerts < ActiveRecord::Migration[7.0]
  def change
    create_table :user_alerts do |t|
      t.string :alert_type, null: false
      t.datetime :read_at, null: true

      t.timestamps
    end
    add_index :user_alerts, :read_at
  end
end
