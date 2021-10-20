class CreateAreasConvictsMapping < ActiveRecord::Migration[6.1]
  def change
    create_table :areas_convicts_mappings do |t|
      t.references :area, polymorphic: true, index: true
      t.references :convict, index: true, foreign_key: true

      t.timestamps
    end
    add_index :areas_convicts_mappings, [:convict_id, :area_id, :area_type], unique: true, name: 'index_areas_convicts_mappings_on_convict_and_area'
  end
end
