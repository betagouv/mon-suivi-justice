class PopulateAgendaIdInSlots < ActiveRecord::Migration[6.1]
  def change
    Slot.all.each do |slot|
      agenda = Agenda.where(place_id: slot.place_id).first
      slot.agenda_id = agenda.id
      slot.save!
    end
  end
end
