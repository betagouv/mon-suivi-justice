class CreateOrganizationDivestments < ActiveRecord::Migration[7.0]
  def change
    create_table :organization_divestments do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :divestment, null: false, foreign_key: true
      t.string :state
      t.date :decision_date
      t.text :comment

      t.timestamps
    end
  end
end
