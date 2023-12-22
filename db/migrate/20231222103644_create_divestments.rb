class CreateDivestments < ActiveRecord::Migration[7.0]
  def change
    create_table :divestments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization_from, null: false, foreign_key: { to_table: :organizations }
      t.references :organization_to, null: false, foreign_key: { to_table: :organizations }
      t.string :state
      t.date :decision_date
      t.text :comment
      
      t.timestamps
    end
  end
end
