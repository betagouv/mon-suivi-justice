class AddCityRefToTjs < ActiveRecord::Migration[6.1]
  def change
    add_reference :tjs, :city, null: false, foreign_key: true
  end
end
