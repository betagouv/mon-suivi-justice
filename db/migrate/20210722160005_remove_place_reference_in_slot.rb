class RemovePlaceReferenceInSlot < ActiveRecord::Migration[6.1]
  def change
    remove_reference :slots, :place, null: false, foreign_key: true
  end
end
