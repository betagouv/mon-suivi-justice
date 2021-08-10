class AddStateToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :state, :string
  end
end
