class AddAgendaReferenceToslot < ActiveRecord::Migration[6.1]
  def change
    add_reference :slots, :agenda, null: true, foreign_key: true
  end
end
