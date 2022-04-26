class AddInvitationAcceptationToConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :timestamp_convict_interface_creation, :datetime
  end
end
