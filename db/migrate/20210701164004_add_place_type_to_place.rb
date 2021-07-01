class AddPlaceTypeToPlace < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :place_type, :integer, default: 0
    add_column :appointment_types, :place_type, :integer, default: 0
  end
end
