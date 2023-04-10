class AddLivesAboradToConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :lives_abroad, :boolean, null: false, default: false
  end
end
