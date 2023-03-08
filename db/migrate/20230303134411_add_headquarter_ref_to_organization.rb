class AddHeadquarterRefToOrganization < ActiveRecord::Migration[6.1]
  def change
    add_reference :organizations, :headquarter, foreign_key: true
  end
end
