class AddUnsubscribeTokenToConvicts < ActiveRecord::Migration[7.1]
  def change
    add_column :convicts, :unsubscribe_token, :string
    add_index :convicts, :unsubscribe_token, unique: true
  end
end
