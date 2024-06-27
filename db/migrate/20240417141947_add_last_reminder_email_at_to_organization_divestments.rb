class AddLastReminderEmailAtToOrganizationDivestments < ActiveRecord::Migration[7.1]
  def change
    add_column :organization_divestments, :last_reminder_email_at, :datetime
  end
end
