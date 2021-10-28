class SeedRescheduleNotificationTypeJob < ApplicationJob
  def perform
    AppointmentType.find_each do |apt_type|
      NotificationType.create appointment_type: apt_type, role: :reschedule, template: seed_template(apt_type)
    end
    Appointment.find_each { |appointment| SeedRescheduleNotificationJob.perform_later(appointment.id) }
  end

  private

  def seed_template(apt_type)
    case apt_type&.name
    when 'RDV de suivi SAP', 'RDV BEX SAP'
      'Votre rendez-vous devant le juge d’application des peines du {rdv.date} à {rdv.heure} a été modifié. '\
      'Vous êtes désormais convoqué.e le {rdv.date} à {rdv.heure} au {lieu.nom} au {lieu.adresse}. '\
      "Pensez à apporter votre pièce d'identité et vos justificatifs. En cas de besoin, vous pouvez contacter le {lieu.téléphone}."
    when 'RDV SAP débat contradictoire'
      'Votre débat contradictoire du {rdv.date} à {rdv.heure} devant le juge d’application des peines a été déplacé. '\
      'Vous êtes désormais convoqué.e le {rdv.date} à {rdv.heure} au {lieu.nom} au {lieu.adresse}. '\
      "Pensez à apporter votre pièce d'identité. En cas de besoin, vous pouvez contacter le {lieu.téléphone}."
    when '1er rdv SPIP', 'Rdv de Suivi SPIP', ' Rdv Bex SPIP', 'Convocation 741)1'
      'Votre rendez-vous au {lieu.nom} le {rdv.date} à {rdv.heure} a été modifié. '\
      'Vous êtes désormais convoqué au {lieu.nom} le {rdv.date} à {rdv.heure}. '\
      "Merci de venir avec une pièce d'identité au {lieu.adresse}. "\
      'En cas de problème, contactez votre conseiller référent ou le standard au {lieu.téléphone}.'
    when 'RDV de placement TIG'
      'Le début de votre TIG le {rdv.date} à {rdv.heure} a été modifié. '\
      'Vous êtes désormais convoqué pour débuter votre TIG le {rdv.date} à {rdv.heure}. '\
      'Merci de vous rendre directement sur le lieu du poste TIG communiqué. '\
      'En cas de problème, contactez votre conseiller référent ou le 0171130200'
        .when 'RDV téléphonique'
      'Votre rendez-vous téléphonique avec le SPIP du {rdv.date} à {rdv.heure} a été modifié. '\
        'Vous avez désormais un rendez-vous téléphonique avec le SPIP le {rdv.date} à {rdv.heure}. '\
        "Merci de vous rendre disponible à l'heure indiquée. "\
        'En cas de problème, contactez votre conseiller référent ou le standard au 01 71 13 02 00.'
    when 'Rdv visite à domicile'
      'Votre rendez-vous le {rdv.date} à {rdv.heure} avec le SPIP pour une visite à domicile a été modifié. '\
      'Vous avez désormais rendez-vous le {rdv.date} à {rdv.heure}. '\
      'En cas de problème, contactez votre conseiller référent ou le standard au 01 71 13 02 00.'
    else
      'Votre rendez-vous le {rdv.date} à {rdv.heure} a été modifié. '\
      'Vous avez désormais rendez-vous le {rdv.date} à {rdv.heure}. '\
      'En cas de problème, contactez votre conseiller référent ou le {lieu.téléphone}.'
    end
  end
end
