# Ajouter un type de convocation

1. Créer les données

D'abord créer en console l'objet AppointmentType lui même :

```
at = AppointmentType.create!(name: 'Action collective')
```

puis tous les templates par défaut associés au nouveau type de convocation :

```
NotificationType.create!(appointment_type: at, role: :summon, template: "Vous êtes convoqué.e par le SPIP le {rdv.date} à {rdv.heure} pour une action collective. Merci de venir avec une pièce d'identité au {lieu.adresse}. En cas de problème, contactez votre conseiller référent ou le standard au {lieu.téléphone}. Plus d'informations sur {lieu.lien_info}", is_default: true)
NotificationType.create!(appointment_type: at, role: :reminder, template: "RAPPEL Vous êtes convoqué.e par le SPIP le {rdv.date} à {rdv.heure} pour une action collective. Merci de venir avec une pièce d'identité au {lieu.adresse}. En cas de problème, contactez votre conseiller référent ou le standard au {lieu.téléphone}. Plus d'informations sur {lieu.lien_info}", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: at, role: :cancelation, template: "Votre convocation du {rdv.date} à {rdv.heure} avec le SPIP est annulé. Votre conseiller référent va vous contacter pour en fixer un nouveau.", is_default: true)
NotificationType.create!(appointment_type: at, role: :no_show, template: "Vous ne vous êtes pas presenté à votre convocation du {rdv.date} à {rdv.heure} avec le SPIP, merci de contacter au plus vite votre conseiller référent ou le standard au {lieu.téléphone}. Plus d'informations sur {lieu.lien_info}", is_default: true)
NotificationType.create!(appointment_type: at, role: :reschedule, template: "Votre convocation au SPIP a été modifié. Vous êtes désormais convoqué au {lieu.nom} le {rdv.date} à {rdv.heure}. Merci de venir avec une pièce d'identité au {lieu.adresse}. Attention, présence impérative. En cas de problème, contactez votre conseiller référent ou le standard au {lieu.téléphone}. Plus d'informations sur {lieu.lien_info}", is_default: true)
```

1. Ajouter le nom du nouveau type de convocation dans les bonnes méthodes du modèle AppointmentType

Selon que le nouveau type de convocation est utilisé par des sap, des spip ou des services bex, ajouter son nom dans la ou les bonnes méthodes (:used_at_bex?, :used_at_sap? et :used_at_spip?).

Si nécessaire, ajouter également ce nom dans les constantes WITH_SLOT_TYPES et ASSIGNABLE.

Déployer ce code.

3. Créer des templates SMS pour tous les services

```
default = NotificationType.where(appointment_type: at)

Organization.all.each do |o|
  NotificationType.roles.each_key do |role|
    new_notif_type = default.where(role: role).first.dup
    new_notif_type.organization = o
    new_notif_type.is_default = false
    new_notif_type.save!
  end
end
```
