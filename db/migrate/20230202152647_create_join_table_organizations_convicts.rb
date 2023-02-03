class CreateJoinTableOrganizationsConvicts < ActiveRecord::Migration[6.1]
  def change
    create_table :convicts_organizations_mappings do |t|
      t.belongs_to :organization
      t.belongs_to :convict
      t.datetime :desactivated_at
      t.timestamps
    end
  end
end
