class CreateUserAlerts < ActiveRecord::Migration[7.0]
  def change
    create_table :user_alerts do |t|
      t.string :alert_type, null: false

      t.timestamps
    end
  end
end
