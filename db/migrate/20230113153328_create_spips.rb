class CreateSpips < ActiveRecord::Migration[6.1]
  def change
    create_table :spips do |t|
      t.string :name
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
