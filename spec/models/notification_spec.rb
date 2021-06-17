require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { should belong_to(:appointment) }

  describe 'format_content' do
    it 'generates SMS content' do
      place = create(:place, name: 'Spip du 03', adress: '38 rue Jean Moulin')
      slot = create(:slot, place: place, date: '02/08/2021', starting_time: new_time_for(16, 30))
      appointment = create(:appointment, slot: slot)

      expected = 'Vous êtes convoqué au Spip du 03 le 02/08/2021 à 16h30.'\
                " Merci d'arriver 15 minutes en avance au 38 rue Jean Moulin."

      notif = Notification.create(appointment_id: appointment.id)

      expect(notif.content).to eq(expected)
    end
  end

  describe 'send_now' do
    it 'calls Sendinblue adapter' do
      Sidekiq::Testing.inline! do
        api_mock = instance_double(SibApiV3Sdk::TransactionalSMSApi)
        allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(api_mock)
        expect(api_mock).to receive(:send_transac_sms)

        notif = create(:notification)
        notif.send_now
      end
    end
  end
end
