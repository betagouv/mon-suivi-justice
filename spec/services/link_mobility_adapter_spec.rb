require 'rails_helper'

RSpec.describe LinkMobilityAdapter do
  before :each do
    @cached_sms_sender = ENV.fetch('SMS_SENDER', nil)
    ENV['SMS_SENDER'] = 'MSJ'
  end

  after :each do
    ENV['SMS_SENDER'] = @cached_sms_sender
  end

  describe 'send_sms' do
    it 'calls LinkMobility API' do
      convict = create(:convict, phone: '0600000000')
      appointment = create(:appointment, convict: convict)
      notif = create(:notification, content: 'Salut', appointment: appointment)

      response = {
        responseCode: 0,
        responseMessage: 'Success',
        messageIds: ['1']
      }.to_json

      stub = stub_request(:post, 'https://europe.ipx.com/restapi/v1/sms/send')
              .to_return(body: response)

      LinkMobilityAdapter.new.send_sms(notif)
      expect(stub).to have_been_requested
    end
  end

  describe 'format_data' do
    it 'prepares data for SMS' do
      convict = create(:convict, phone: '0622334455')
      appointment = create(:appointment, convict: convict)

      notif = create(:notification, appointment: appointment)
      notif.content = 'Bonjour'

      expected = {
        destinationAddress: '+33622334455',
        messageText: 'Bonjour',
        originatorTON: 1,
        originatingAddress: 'MSJ',
        maxConcatenatedMessages: 10
      }

      result = LinkMobilityAdapter.new.format_data(notif)

      expect(result).to eq(expected)
    end
  end
end
