class AddRoleToNotification < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :role, :integer, default: 0
    add_column :notifications, :template, :string
  end
end
