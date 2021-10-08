class CreateAreasOrganizationsMapping < ActiveRecord::Migration[6.1]
  def change
    create_table :areas_organizations_mappings do |t|
      t.references :area, polymorphic: true, index: true
      t.references :organization, index: true, foreign_key: true
      
      t.timestamps
    end
  end
end
