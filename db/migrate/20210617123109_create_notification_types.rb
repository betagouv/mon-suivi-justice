class CreateNotificationTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :notification_types do |t|
      t.references :appointment_type, index: true, foreign_key: true
      t.text :template
      t.integer :role, default: 0

      t.timestamps
    end
  end
end
