class CreateTjs < ActiveRecord::Migration[6.1]
  def change
    create_table :tjs do |t|
      t.string :name
      t.references :organization, null: true, foreign_key: true

      t.timestamps
    end
  end
end
