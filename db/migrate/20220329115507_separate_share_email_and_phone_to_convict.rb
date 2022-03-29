class SeparateShareEmailAndPhoneToConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :share_email_to_convict, :boolean, default: true
    add_column :users, :share_phone_to_convict, :boolean, default: true
    remove_column :users, :share_info_to_convict, :boolean
  end
end
