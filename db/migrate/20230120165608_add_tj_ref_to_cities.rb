class AddTjRefToCities < ActiveRecord::Migration[6.1]
  def change
    add_reference :cities, :tj, null: true, foreign_key: true
  end
end
