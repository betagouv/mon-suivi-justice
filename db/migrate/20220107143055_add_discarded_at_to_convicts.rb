class AddDiscardedAtToConvicts < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :discarded_at, :datetime
    add_index :convicts, :discarded_at
  end
end
