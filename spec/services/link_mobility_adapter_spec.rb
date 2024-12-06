require 'rails_helper'

# refaire check complet
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
      appointment = create(:appointment, convict:)
      notif = create(:notification, state: :programmed, content: 'Salut', appointment:)

      response = {
        responseCode: 0,
        responseMessage: 'Success',
        messageIds: ['1']
      }.to_json

      stub = stub_request(:post, 'https://europe.ipx.com/restapi/v1/sms/send')
              .to_return(body: response)

      result = LinkMobilityAdapter.new(notif).send_sms
      expect(stub).to have_been_requested
      expect(result).to be_an_instance_of(SmsApiResponse)
      expect(result.success).to eq(true)
      expect(result.external_id).to eq('1')
      expect(result.code).to eq(0)
      expect(result.message).to eq('Success')
      expect(result.retry_if_failed).to eq(false)
    end
  end

  describe 'format_data' do
    let(:convict) { create(:convict, phone: '0622334455') }

    it 'prepares data for SMS' do
      appointment = create(:appointment, convict:)

      notif = create(:notification, appointment:, state: :programmed)
      notif.content = 'Bonjour'

      expected = {
        destinationAddress: '+33622334455',
        messageText: "Bonjour Stop SMS: http://localhost/stop_sms?token=#{convict.unsubscribe_token}",
        originatorTON: 1,
        originatingAddress: 'MSJ',
        maxConcatenatedMessages: 10
      }

      result = LinkMobilityAdapter.new(notif).send(:sms_data)

      expect(result).to eq(expected)
    end
  end
end
