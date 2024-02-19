class AddSecurityCharterAcceptedAtToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :security_charter_accepted_at, :datetime
  end
end
