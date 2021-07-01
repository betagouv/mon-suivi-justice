class CreateSlotTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :slot_types do |t|
      t.integer :week_day, default: 0
      t.time :starting_time
      t.integer :duration, default: 30
      t.integer :capacity, default: 1

      t.references :appointment_type, index: true, foreign_key: true
      t.timestamps
    end
  end
end
