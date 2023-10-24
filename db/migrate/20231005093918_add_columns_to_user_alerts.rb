class AddColumnsToUserAlerts < ActiveRecord::Migration[7.0]
  def change
    add_column :user_alerts, :services, :string
    add_column :user_alerts, :roles, :string
  end
end
