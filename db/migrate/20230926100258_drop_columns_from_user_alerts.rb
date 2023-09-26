class DropColumnsFromUserAlerts < ActiveRecord::Migration[7.0]
  def change
    remove_column :user_alerts, :recipient_type, :string
    remove_column :user_alerts, :recipient_id, :bigint
    remove_column :user_alerts, :params, :jsonb
  end
end
