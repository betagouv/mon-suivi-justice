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
    let(:convict) { create(:convict, phone: '0600000000') }
    let(:appointment) { create(:appointment, convict:) }
    let(:notif) { create(:notification, content: 'Salut', appointment:, state: :programmed) }
    let(:response) do
      {
        responseCode: 0,
        responseMessage: 'Success',
        messageIds: ['1']
      }.to_json
    end

    before do
      @stub = stub_request(:post, 'https://europe.ipx.com/restapi/v1/sms/send')
                .to_return(body: response)
      LinkMobilityAdapter.new.send_sms(notif)
    end

    it 'calls LinkMobility API' do
      expect(@stub).to have_been_requested
    end

    it 'updates notification with external_id' do
      expect(notif.reload.external_id).to eq('1')
    end

    it 'marks notification as sent' do
      expect(notif.reload.state).to eq('sent')
    end
  end

  describe 'format_data' do
    it 'prepares data for SMS' do
      convict = create(:convict, phone: '0622334455')
      appointment = create(:appointment, convict:)

      notif = create(:notification, appointment:)
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
