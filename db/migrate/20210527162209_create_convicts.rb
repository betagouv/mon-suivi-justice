class CreateConvicts < ActiveRecord::Migration[6.1]
  def change
    create_table :convicts do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone

      t.timestamps
    end
  end
end
