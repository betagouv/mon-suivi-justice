class AddDeleteAtColumnOnConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :deleted_at, :datetime
  end
end
