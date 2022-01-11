class RemoveDeletedAtFromConvict < ActiveRecord::Migration[6.1]
  def change
    remove_column :convicts, :deleted_at, :datetime
  end
end
