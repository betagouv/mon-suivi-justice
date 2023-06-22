class ChangeDefaultValueForUserRole < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :role, from: 0, to: 2 
  end
end
