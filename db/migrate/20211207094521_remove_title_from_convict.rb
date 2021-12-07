class RemoveTitleFromConvict < ActiveRecord::Migration[6.1]
  def change
    remove_column :convicts, :title, :integer
  end
end
