class AddPhoneDataToConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :no_phone, :boolean
    add_column :convicts, :refused_phone, :boolean
  end
end
