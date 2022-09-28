class RemoveArchivedFromPlaces < ActiveRecord::Migration[6.1]
  def change
    remove_column :places, :archived, :boolean
  end
end
