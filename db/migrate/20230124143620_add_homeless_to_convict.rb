class AddHomelessToConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :homeless, :boolean, null: false, default: false
  end
end
