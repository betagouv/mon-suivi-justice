require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { should belong_to(:appointment) }
  it { should validate_presence_of(:template) }
  it { should define_enum_for(:role).with_values(%i[summon reminder]) }

  describe 'format_content' do
    it 'generates SMS content' do
      place = create(:place, name: 'Spip du 03', adress: '38 rue Jean Moulin')
      slot = create(:slot, place: place, date: '02/08/2021', starting_time: new_time_for(16, 30))

      appointment_type = create(:appointment_type)
      sms_template = 'Vous êtes convoqué au {lieu.nom} le {rdv.date} à {rdv.heure}.'\
                     " Merci de venir avec une pièce d'identité au {lieu.adresse}."

      create(:notification_type, appointment_type: appointment_type, template: sms_template)

      appointment = create(:appointment, appointment_type: appointment_type, slot: slot)

      expected = 'Vous êtes convoqué au Spip du 03 le 02/08/2021 à 16h30.'\
                " Merci de venir avec une pièce d'identité au 38 rue Jean Moulin."

      NotificationFactory.perform(appointment)

      notif = appointment.notifications.last

      expect(notif.content).to eq(expected)
    end
  end

  describe 'send_now' do
    it 'calls Sendinblue adapter' do
      Sidekiq::Testing.inline! do
        api_mock = instance_double(SibApiV3Sdk::TransactionalSMSApi)
        allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(api_mock)
        allow_any_instance_of(Notification).to receive(:format_content)

        expect(api_mock).to receive(:send_transac_sms)

        notif = create(:notification)
        notif.send_now
      end
    end
  end
end
