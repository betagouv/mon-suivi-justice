class ChangeReferenceForSlots < ActiveRecord::Migration[6.1]
  def default_agenda_for_spip
    place = Place.where(place_type: :spip).first
    return if place.nil?
    agenda = Agenda.create(name: 'SPIP 92', place_id: place.id)
    agenda.id
  end

  def change
    remove_reference :slots, :place, index: true, foreign_key: true
    add_reference :slots, :agenda, null: false, foreign_key: true, default: default_agenda_for_spip
  end
end
