class AddConditionalUniqueIndexToDivestments < ActiveRecord::Migration[7.0]
  def change
    add_index :divestments, [:convict_id, :state], unique: true, where: "state = 'pending'"
  end
end
