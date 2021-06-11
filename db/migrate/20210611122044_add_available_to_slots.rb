class AddAvailableToSlots < ActiveRecord::Migration[6.1]
  def change
    add_column :slots, :available, :boolean, default: true
  end
end
