class CreateAreasOrganizationsMapping < ActiveRecord::Migration[6.1]
  def change
    create_table :areas_organizations_mappings do |t|
      t.references :area, polymorphic: true, index: true
      t.references :organization, index: true, foreign_key: true

      t.timestamps
    end
    add_index :areas_organizations_mappings, [:organization_id, :area_id, :area_type], unique: true, name: 'index_areas_organizations_mappings_on_organization_and_area'
  end
end
