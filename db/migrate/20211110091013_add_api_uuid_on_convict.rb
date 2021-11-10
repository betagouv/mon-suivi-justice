class AddApiUuidOnConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :appi_uuid, :string, index: { unique: true }
  end
end
