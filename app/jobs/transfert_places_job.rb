class TransfertPlacesJob < ApplicationJob
  def perform(tranfert_place)
    @transfert_place = tranfert_place
    @old_place = @transfert_place.old_place
    @new_place = @transfert_place.new_place

    p old_place: @old_place, new_place: @new_place
    # move appointments from old place to new place after transfert date
    # Les créneaux dans l’ancien lieu après la date de déménagement sont supprimés et la création de nouveaux créneaux après cette date est bloquée
    # La création de RDVs (notamment suivi SPIP) dans l’ancien lieu après la date de déménagement est bloquée
    # Le contenu des notifications SMS déjà prévues pour les RDVs qui auront lieu après le déménagement est modifié pour indiquer l’adresse du nouveau lieu
    # Après le déménagement, les anciens lieux du SPIP 78 sont archivés
  end
end
