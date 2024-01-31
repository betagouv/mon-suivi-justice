class CreateDivestments < ActiveRecord::Migration[7.0]
  def change
    create_table :divestments do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :convict, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :state
      t.date :decision_date
      
      t.timestamps
    end
  end
end
