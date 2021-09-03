class AddCategoryToHistoryItems < ActiveRecord::Migration[6.1]
  def change
    add_column :history_items, :category, :integer, default: 0
  end
end
