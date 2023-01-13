class AddSpipReferencesToCities < ActiveRecord::Migration[6.1]
  def change
    add_reference :cities, :spip, null: false, foreign_key: true
  end
end
