class MoveSlotRefereceFromAgendaToSlotType < ActiveRecord::Migration[6.1]
  def change
    add_reference :slots, :slot_type, foreign_key: true, index: true
    add_reference :slot_types, :agenda, foreign_key: true, index: true
  end
end
