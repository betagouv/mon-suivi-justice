class AddResponseCodeToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :response_code, :string
    add_column :notifications, :target_phone, :string
  end
end
