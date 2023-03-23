class CreateTableSpipsAndTjs < ActiveRecord::Migration[6.1]
  def change
    create_table :spips_tjs, id: false do |t|
      t.belongs_to :tj, foreign_key: { to_table: :organizations }
      t.belongs_to :spip, foreign_key: { to_table: :organizations }
      t.timestamps
    end
  end
end
