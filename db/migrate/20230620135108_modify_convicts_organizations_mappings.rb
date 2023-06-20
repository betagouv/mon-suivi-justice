class ModifyConvictsOrganizationsMappings < ActiveRecord::Migration[6.1]
  def change
    change_column_null :convicts_organizations_mappings, :organization_id, false
    change_column_null :convicts_organizations_mappings, :convict_id, false
    add_index :convicts_organizations_mappings, [:organization_id, :convict_id], unique: true, name: 'index_convicts_organizations_mappings_on_org_id_and_convict_id'
  end
end
