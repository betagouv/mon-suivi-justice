class AddIndexToNotificationsDeliveryTimeAndState < ActiveRecord::Migration[7.1]
  def change
    add_index :notifications, [:delivery_time, :state]
  end
end
