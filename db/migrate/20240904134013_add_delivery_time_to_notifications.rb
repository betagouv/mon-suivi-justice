class AddDeliveryTimeToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :delivery_time, :datetime
  end
end
