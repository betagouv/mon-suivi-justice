require 'rails_helper'

RSpec.describe NotificationFactory do
  describe 'perform' do
    it 'creates notifications for an appointment' do
      appointment_type = create(:appointment_type)
      create(:notification_type, appointment_type: appointment_type,
                                 role: :summon,
                                 template: 'RDV pris le {rdv.date} à {rdv.heure}')
      create(:notification_type, appointment_type: appointment_type,
                                 role: :reminder,
                                 template: 'Rappel: rdv le {rdv.date} à {rdv.heure}')
      slot = create(:slot, date: Date.civil(2025,4,14), starting_time: new_time_for(15, 30),
                           appointment_type: appointment_type)
      appointment = create(:appointment, slot: slot)

      expect { NotificationFactory.perform(appointment) }.to change { Notification.count }.by(2)

      appointment.reload
      expect(appointment.notifications.count).to eq(2)

      summon_notif = appointment.notifications.where(role: :summon).first
      reminder_notif = appointment.notifications.where(role: :reminder).first

      expect(summon_notif.content).to eq("RDV pris le #{Date.civil(2025,4,14)} à 15h30")
      expect(reminder_notif.content).to eq("Rappel: rdv le #{Date.civil(2025,4,14)} à 15h30")
    end
  end

  describe 'setup_template' do
    it 'translates human readable template into a ruby usable one' do
      human_template = 'RDV pris le {rdv.date} à {rdv.heure}'
      expected = 'RDV pris le %{appointment_date} à %{appointment_hour}'

      result = NotificationFactory.setup_template(human_template)

      expect(result).to eq(expected)
    end
  end

  describe 'format_content' do
    it 'generates SMS content' do
      appointment_type = create(:appointment_type)
      place = create(:place, name: 'Spip du 03',
                             adress: '38 rue Jean Moulin',
                             phone: '0102030405',
                             main_contact_method: 1,
                             contact_email: 'test@test.com',
                             preparation_link: 'https://mon-suivi-justice.beta.gouv.fr/preparer_spip92')
      agenda = create(:agenda, place: place)
      slot = create(:slot, agenda: agenda,
                           date: Date.civil(2025,4,18),
                           starting_time: new_time_for(16, 30), appointment_type: appointment_type)
      sms_template = 'Vous êtes convoqué au {lieu.nom} le {rdv.date} à {rdv.heure}.'\
                     " Merci de venir avec une pièce d'identité au {lieu.adresse}." \
                     ' Veuillez contacter le {lieu.téléphone} (ou {lieu.contact})' \
                     ' en cas de problème. Plus d\'informations sur {lieu.lien_info}.'
      create(:notification_type, appointment_type: appointment_type, template: sms_template)

      appointment = create(:appointment, slot: slot)

      expected = "Vous êtes convoqué au Spip du 03 le #{Date.civil(2025,4,18)} à 16h30."\
                 " Merci de venir avec une pièce d'identité au 38 rue Jean Moulin."\
                 ' Veuillez contacter le 0102030405 (ou test@test.com) en cas de problème.'\
                 " Plus d'informations sur https://mon-suivi-justice.beta.gouv.fr/preparer_spip92."

      NotificationFactory.perform(appointment)

      notif = appointment.notifications.last

      expect(notif.content).to eq(expected)
    end
  end
end
