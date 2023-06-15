module NotificationHelpers
  def convocation_template(place)
    "Votre rendez-vous au SPIP a été modifié. Vous êtes désormais convoqué au #{place.name} le 08/08/2023 à 09h45.
    Merci de venir avec une pièce d'identité au #{place.adress}.
    En cas de problème, contactez votre conseiller référent ou le standard au #{place.display_phone}.
    Plus d'informations sur https://mon-suivi-justice.beta.gouv.fr/preparer_spip_loiret_montargis"
  end
end
