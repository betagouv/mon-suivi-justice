class ChangeVersionsObjectToJsonb < ActiveRecord::Migration[7.0]
  def change
    rename_column :versions, :object, :old_object
    add_column :versions, :object, :jsonb

    rename_column :versions, :object_changes, :old_object_changes
    add_column :versions, :object_changes, :jsonb
  end
end
