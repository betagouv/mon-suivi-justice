class TransfertPlacesJob < ApplicationJob
  def perform(tranfert_place)
    @transfert_place = tranfert_place
    @old_place = @transfert_place.old_place
    @new_place = @transfert_place.new_place

    p old_place: @old_place, new_place: @new_place
    # Le contenu des notifications SMS déjà prévues pour les RDVs qui auront lieu après le déménagement est modifié pour indiquer l’adresse du nouveau lieu
    # les anciens lieux du SPIP 78 sont archivés
  end
end
