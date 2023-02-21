class CreateExtraFields < ActiveRecord::Migration[6.1]
  def change
    create_table :extra_fields do |t|
      t.references :organization, null: false, foreign_key: true
      t.column :data_type, :string, default: "text"
      t.string :name, null: false
      t.timestamps
    end
  end
end
