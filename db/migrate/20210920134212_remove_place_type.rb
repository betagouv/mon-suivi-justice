class RemovePlaceType < ActiveRecord::Migration[6.1]
  def change
    remove_column :places, :place_type, :integer
    remove_column :appointment_types, :place_type, :integer
  end
end
