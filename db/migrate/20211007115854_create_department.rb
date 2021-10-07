class CreateDepartment < ActiveRecord::Migration[6.1]
  def change
    create_table :departments do |t|
      t.string :number, unique: true, null: false
      t.string :name, unique: true, null: false
      
      t.timestamps
    end
  end
end
