class MoveSlotRefereceFromAgendaToSlotType < ActiveRecord::Migration[6.1]
  def change
    remove_column :slots, :agenda_id, :reference, foreign_key: true, index: true
    add_reference :slots, :slot_type, foreign_key: true, index: true
  end
end
