class AddCompetenceJapatToConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :japat, :boolean, null: false, default: false
  end
end
