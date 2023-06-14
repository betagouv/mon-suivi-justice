class CreatePlaceTransfert < ActiveRecord::Migration[6.1]
  def change
    create_table :place_transferts do |t|
      t.references :new_place
      t.references :old_place
      t.integer :status, default: 0
      t.date :date

      t.index [:new_place_id, :old_place_id]
      t.index [:old_place_id, :new_place_id]

      t.timestamps
    end
  end
end
