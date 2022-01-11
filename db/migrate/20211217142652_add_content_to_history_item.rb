class AddContentToHistoryItem < ActiveRecord::Migration[6.1]
  def change
    add_column :history_items, :content, :text
  end
end
