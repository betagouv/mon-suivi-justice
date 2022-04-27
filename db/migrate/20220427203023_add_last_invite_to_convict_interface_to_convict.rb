class AddLastInviteToConvictInterfaceToConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :last_invite_to_convict_interface, :datetime
  end
end
