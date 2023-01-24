class AddSpipRefToCities < ActiveRecord::Migration[6.1]
  def change
    add_reference :cities, :spip, null: true, foreign_key: true
  end
end
