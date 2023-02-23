class AddCreatingOrganizationToConvicts < ActiveRecord::Migration[6.1]
  def change
    add_reference :convicts, :creating_organization, null: true, foreign_key: { to_table: :organizations }
  end
end
