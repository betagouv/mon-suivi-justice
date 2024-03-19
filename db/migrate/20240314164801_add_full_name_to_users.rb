class AddFullNameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :full_name, :virtual, type: :string, as: "first_name || ' ' || last_name", stored: true
  end
end
