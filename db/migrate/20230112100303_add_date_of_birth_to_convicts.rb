class AddDateOfBirthToConvicts < ActiveRecord::Migration[6.1]
  def change
    add_column :convicts, :date_of_birth, :date
  end
end
