class TransfertPlacesJob < ApplicationJob
  def perform
    place_transferts = PlaceTransfert.where('date = ?', Date.today)

    place_transferts.each do |transfert_place|
      p "TransfertPlacesJob: archive place: #{transfert_place.old_place.name}"

      transfert_place.old_place.discard
      transfert_place.old_place.agendas.discard_all
      transfert_place.old_place.agendas.each do |agenda|
        agenda.slot_types.discard_all
      end
    end
  end
end
