class CreateHeadquarters < ActiveRecord::Migration[6.1]
  def change
    create_table :headquarters do |t|
      t.string :name

      t.timestamps
    end
  end
end
