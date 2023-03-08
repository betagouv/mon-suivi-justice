class AddScopeToExtraField < ActiveRecord::Migration[6.1]
  def change
    add_column :extra_fields, :scope, :string, null: false, default: "appointment_update"
  end
end
