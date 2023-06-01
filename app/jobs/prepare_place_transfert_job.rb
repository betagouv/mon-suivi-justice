class PreparePlaceTransfertJob < ApplicationJob
  def perform(tranfert_place)
    @transfert_place = tranfert_place
    @old_place = @transfert_place.old_place
    @new_place = @transfert_place.new_place

    p old_place: @old_place, new_place: @new_place
    # duplicates angendas from old place to new place
    # move slot from old place to new place after transfert date
    @old_place.agendas.each do |agenda|
      new_place_agenda = agenda.dup
      new_place_agenda.place = @new_place
      if new_place_agenda.save
        agenda.slots.where('date >= ?', @transfert_place.date).update_all(agenda_id: new_place_agenda.id)
      end
    end
  end
end
