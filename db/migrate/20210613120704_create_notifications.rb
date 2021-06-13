class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.string :name
      t.text :content

      t.references :appointment_type, index: true, foreign_key: true
      t.timestamps
    end
  end
end
