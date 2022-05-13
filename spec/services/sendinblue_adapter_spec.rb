require 'rails_helper'

RSpec.describe SendinblueAdapter do
  before :each do
    @cached_sms_sender = ENV['SMS_SENDER']
    ENV['SMS_SENDER'] = 'MSJ'
  end

  after :each do
    ENV['SMS_SENDER'] = @cached_sms_sender
  end

  describe 'send_sms' do
    it 'calls Sendinblue API' do
      notif = build(:notification)
      sib_api_mock = instance_double(SibApiV3Sdk::TransactionalSMSApi)
      api_result = double(message_id: '111')

      allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(sib_api_mock)
      expect(sib_api_mock).to receive(:send_transac_sms).and_return(api_result)

      SendinblueAdapter.new.send_sms(notif)
    end
  end

  describe 'get_sms_status' do
    it 'calls Sendinblue API' do
      notif = build(:notification)
      sib_api_mock = instance_double(SibApiV3Sdk::TransactionalSMSApi)
      allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(sib_api_mock)
      expect(sib_api_mock).to receive(:get_sms_events)

      adapter = SendinblueAdapter.new
      allow(adapter).to receive(:set_notification_state)

      adapter.get_sms_status(notif)
    end
  end

  describe 'format_data' do
    it 'prepares data for SMS' do
      convict = create(:convict, phone: '0622334455')
      appointment = create(:appointment, convict: convict)

      notif = create(:notification, appointment: appointment)
      notif.content = 'Bonjour'

      expected = {
        sender: 'MSJ',
        recipient: '+33622334455',
        content: 'Bonjour'
      }

      result = SendinblueAdapter.new.format_data(notif, { resent: false })

      expect(result).to eq(expected)
    end
  end
end
