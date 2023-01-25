class AddStructureIdToSpips < ActiveRecord::Migration[6.1]
  def change
    add_column :spips, :structure_id, :string
    add_index :spips, :structure_id
  end
end
