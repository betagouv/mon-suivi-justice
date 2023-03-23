class RemoveLinkedOrganizationRefFromOrganization < ActiveRecord::Migration[6.1]
  def change
    remove_column :organizations, :linked_organization_id, :reference
  end
end
