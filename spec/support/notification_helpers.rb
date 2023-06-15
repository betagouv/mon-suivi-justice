module NotificationHelpers
  def convocation_template(place)
    "Votre rendez-vous au SPIP a été modifié. Vous êtes désormais convoqué au #{place.name} le 08/08/2023 à 09h45.
    Merci de venir avec une pièce d'identité au #{place.adress}.
    En cas de problème, contactez votre conseiller référent ou le standard au #{place.display_phone} ou par mail #{place.contact_email}.
    Plus d'informations sur #{place.preparation_link}"
  end
end
