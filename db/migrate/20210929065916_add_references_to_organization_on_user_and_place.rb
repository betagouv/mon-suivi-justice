class AddReferencesToOrganizationOnUserAndPlace < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :organization, foreign_key: true
    add_reference :places, :organization, foreign_key: true
  end
end
