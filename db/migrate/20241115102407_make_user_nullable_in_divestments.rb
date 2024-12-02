class MakeUserNullableInDivestments < ActiveRecord::Migration[7.1]
  def change
    change_column_null :divestments, :user_id, true
  end
end
