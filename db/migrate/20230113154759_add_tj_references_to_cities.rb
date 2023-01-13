class AddTjReferencesToCities < ActiveRecord::Migration[6.1]
  def change
    add_reference :cities, :tj, null: false, foreign_key: true
  end
end
