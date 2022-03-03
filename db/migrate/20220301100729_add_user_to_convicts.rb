class AddUserToConvicts < ActiveRecord::Migration[6.1]
  def change
    add_reference :convicts, :user, foreign_key: true
  end
end
