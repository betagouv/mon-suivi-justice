class CreateHistoryItems < ActiveRecord::Migration[6.1]
  def change
    create_table :history_items do |t|
      t.integer :event, default: 0

      t.references :convict, index: true, foreign_key: true
      t.references :appointment, index: true, foreign_key: true
      t.timestamps
    end
  end
end
