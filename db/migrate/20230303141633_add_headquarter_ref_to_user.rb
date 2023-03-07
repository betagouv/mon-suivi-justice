class AddHeadquarterRefToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :headquarter, foreign_key: true
  end
end
