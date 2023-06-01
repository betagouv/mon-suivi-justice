class TransfertPlacesJob < ApplicationJob
  def perform
    place_transferts = PlaceTransfert.where('date = ?', Date.today)

    place_transferts.each do |transfert_place|
      p "TransfertPlacesJob: archive place: #{transfert_place.old_place.name}"
      archive(transfert_place.old_place)
    end
    # Le contenu des notifications SMS déjà prévues pour les RDVs qui auront lieu après le déménagement est modifié pour indiquer l’adresse du nouveau lieu
    # les anciens lieux du SPIP 78 sont archivés
  end
end
