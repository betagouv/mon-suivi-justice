class AddDataToSlot < ActiveRecord::Migration[6.1]
  def change
    add_column :slots, :duration, :integer, default: 30
    add_column :slots, :capacity, :integer, default: 1
  end
end
