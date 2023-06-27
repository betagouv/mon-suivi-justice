class ChangeDefaultValueForUserRole < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :role, nil
    change_column_null :users, :role, false
  end
end
