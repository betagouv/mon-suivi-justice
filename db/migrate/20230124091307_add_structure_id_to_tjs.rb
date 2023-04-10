class AddStructureIdToTjs < ActiveRecord::Migration[6.1]
  def change
    add_column :tjs, :structure_id, :string
    add_index :tjs, :structure_id
  end
end
