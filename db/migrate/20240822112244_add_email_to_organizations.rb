class AddEmailToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :email, :string
  end
end
