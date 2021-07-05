class AddUsedCapacityToSlot < ActiveRecord::Migration[6.1]
  def change
    add_column :slots, :used_capacity, :integer, default: 0
  end
end
