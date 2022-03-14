class AddFullToSlot < ActiveRecord::Migration[6.1]
  def change
    add_column :slots, :full, :boolean, default: false
  end
end
