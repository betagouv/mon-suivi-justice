class CreateSlots < ActiveRecord::Migration[6.1]
  def change
    create_table :slots do |t|
      t.date :date
      t.time :starting_time

      t.references :place, index: true, foreign_key: true
      t.timestamps
    end
  end
end
