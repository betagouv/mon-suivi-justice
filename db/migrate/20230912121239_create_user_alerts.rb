class CreateUserAlerts < ActiveRecord::Migration[7.0]
  def change
    create_table :user_alerts do |t|
      t.string :type, null: false
      t.datetime :read_at

      t.timestamps
    end
    add_index :user_alerts, :read_at
  end
end
