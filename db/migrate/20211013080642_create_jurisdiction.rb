class CreateJurisdiction < ActiveRecord::Migration[6.1]
  def change
    create_table :jurisdictions do |t|
      t.string :name, index: {unique: true}, null: false

      t.timestamps
    end
  end
end
