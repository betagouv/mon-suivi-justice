class CreateJoinTableOrganizationsConvicts < ActiveRecord::Migration[6.1]
  def change
    create_table :organizations_convicts do |t|
      t.belongs_to :organization
      t.belongs_to :convict
      t.datetime :desactivated_at
      t.timestamps
    end
  end
end
