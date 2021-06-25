require 'rails_helper'

RSpec.describe SendinblueAdapter do
  describe 'send_sms' do
    it 'calls Sendinblue API' do
      notif = build(:notification)
      sib_api_mock = instance_double(SibApiV3Sdk::TransactionalSMSApi)
      allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(sib_api_mock)
      expect(sib_api_mock).to receive(:send_transac_sms)

      SendinblueAdapter.new.send_sms(notif)
    end
  end

  describe 'format_data' do
    it 'prepares data for SMS' do
      allow_any_instance_of(Notification).to receive(:format_content)

      convict = create(:convict, phone: '0622334455')
      appointment = create(:appointment, convict: convict)

      notif = create(:notification, appointment: appointment)
      notif.content = 'Bonjour'

      expected = {
        sender: 'MSJ',
        recipient: '+33622334455',
        content: 'Bonjour'
      }

      result = SendinblueAdapter.new.format_data(notif)

      expect(result).to eq(expected)
    end
  end
end
