class AddExternalIdToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :external_id, :string
  end
end
