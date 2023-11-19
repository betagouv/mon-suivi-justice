class AddFullNameToConvict < ActiveRecord::Migration[7.0]
  def change
    add_column :convicts, :full_name, :virtual, type: :string, as: "first_name || ' ' || last_name", stored: true
  end
end
