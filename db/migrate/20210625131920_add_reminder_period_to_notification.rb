class AddReminderPeriodToNotification < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :reminder_period, :integer, default: 0
    add_column :notification_types, :reminder_period, :integer, default: 0
  end
end
