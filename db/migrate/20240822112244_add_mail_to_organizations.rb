class AddMailToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :mail, :string
  end
end
