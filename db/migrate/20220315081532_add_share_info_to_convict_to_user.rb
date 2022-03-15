class AddShareInfoToConvictToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :share_info_to_convict, :boolean, null: false, default: true
  end
end
