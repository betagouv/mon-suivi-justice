class DropDepartmentTableAndAssociated < ActiveRecord::Migration[7.1]
  def change
    drop_table :departments
    drop_table :areas_organizations_mappings
    drop_table :areas_convicts_mappings
    drop_table :jurisdictions
  end
end
