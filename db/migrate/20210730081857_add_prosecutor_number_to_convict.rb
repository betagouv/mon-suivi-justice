class AddProsecutorNumberToConvict < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :prosecutor_number, :string
  end
end
