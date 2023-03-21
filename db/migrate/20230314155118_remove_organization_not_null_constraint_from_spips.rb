class RemoveOrganizationNotNullConstraintFromSpips < ActiveRecord::Migration[6.1]
  def change
    change_column_null :spips, :organization_id, true
  end
end
