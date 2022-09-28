class AddDiscardedAtToSlotTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :slot_types, :discarded_at, :datetime
    add_index :slot_types, :discarded_at
  end
end
