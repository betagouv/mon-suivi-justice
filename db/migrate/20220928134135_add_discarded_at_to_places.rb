class AddDiscardedAtToPlaces < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :discarded_at, :datetime
    add_index :places, :discarded_at
  end
end
