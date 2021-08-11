class RemoveNameFromNotifications < ActiveRecord::Migration[6.1]
  def change
    remove_column :notifications, :name, :string
  end
end
