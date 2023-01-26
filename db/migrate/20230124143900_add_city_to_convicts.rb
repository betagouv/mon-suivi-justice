class AddCityToConvicts < ActiveRecord::Migration[6.1]
  def change
    add_reference :convicts, :city, null: true, foreign_key: true, index: true
  end
end
