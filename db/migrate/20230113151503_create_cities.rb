class CreateCities < ActiveRecord::Migration[6.1]
  def change
    create_table :cities do |t|
      t.string :name, null: false, index: true
      t.string :zipcode, null: false, index: true
      t.string :code_insee

      t.timestamps
    end
  end
end
