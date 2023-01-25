class AddIndexToCities < ActiveRecord::Migration[6.1]
  def change
    add_column :cities, :city_id, :string
    add_index :cities, :city_id
  end
end
