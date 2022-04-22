class AddInvitationToConvictInterfaceCountToConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :invitation_to_convict_interface_count, :integer, default: 0, null: false
  end
end
