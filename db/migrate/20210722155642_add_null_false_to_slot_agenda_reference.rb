class AddNullFalseToSlotAgendaReference < ActiveRecord::Migration[6.1]
  def change
    change_column_null :slots, :agenda_id, false
  end
end
