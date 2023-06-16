class TransfertPlacesJob < ApplicationJob
  def perform
    place_transferts = PlaceTransfert.where('date <= ? AND status = ?', Date.today, 0)

    place_transferts.each do |transfert_place|
      archive_place(transfert_place.old_place)
      transfert_place.status = 'transfert_done'
      transfert_place.save(validate: false)
    end
  end

  def archive_place(place)
    p "TransfertPlacesJob: archive place: #{place.name}"

    place.discard
    place.agendas.discard_all
    place.agendas.each do |agenda|
      agenda.slot_types.discard_all
    end
  end
end
