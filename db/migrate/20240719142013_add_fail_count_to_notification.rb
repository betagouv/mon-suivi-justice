class AddFailCountToNotification < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :failed_count, :integer, default: 0, null: false
  end
end
