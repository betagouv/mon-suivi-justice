class TransfertPlacesJob < ApplicationJob
  def perform
    place_transferts = PlaceTransfert.where('date = ?', Date.today)

    place_transferts.each do |transfert_place|
      p "TransfertPlacesJob: archive place: #{transfert_place.old_place.name}"
      archive(transfert_place.old_place)
    end
  end
end
