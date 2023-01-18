class AddCityRefToSpips < ActiveRecord::Migration[6.1]
  def change
    add_reference :spips, :city, null: false, foreign_key: true
  end
end
