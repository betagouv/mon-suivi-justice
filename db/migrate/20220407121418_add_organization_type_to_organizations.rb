class AddOrganizationTypeToOrganizations < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :organization_type, :integer, default: 0
  end
end
