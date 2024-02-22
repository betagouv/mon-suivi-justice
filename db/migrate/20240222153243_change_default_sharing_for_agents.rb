class ChangeDefaultSharingForAgents < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :share_email_to_convict, false
    change_column_default :users, :share_phone_to_convict, false
  end
end
