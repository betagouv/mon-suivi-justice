class CreateJuridiction < ActiveRecord::Migration[6.1]
  def change
    create_table :juridictions do |t|
      t.string :name, index: {unique: true}, null: false

      t.timestamps
    end
  end
end
