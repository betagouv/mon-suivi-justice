class AddIsDefaultToNotificationType < ActiveRecord::Migration[6.1]
  def change
    add_column :notification_types, :is_default, :boolean, default: false, null: false
    add_column :notification_types, :still_default, :boolean, default: true, null: false
  end
end
