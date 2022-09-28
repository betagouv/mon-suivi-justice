class AddArchivedToPlaces < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :archived, :boolean, default: false, null: false
  end
end
