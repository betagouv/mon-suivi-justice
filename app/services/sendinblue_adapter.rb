class SendinblueAdapter
  def initialize
    SibApiV3Sdk.configure do |config|
      config.api_key['api-key'] = ENV['SIB_API_KEY']
      config.api_key['partner-key'] = ENV['SIB_API_KEY']
    end

    @client = SibApiV3Sdk::TransactionalSMSApi.new
  end

  def send_sms
    sms = SibApiV3Sdk::SendTransacSms.new(sms_data)

    begin
      @client.send_transac_sms(sms)
    rescue SibApiV3Sdk::ApiError => e
      puts "Exception when calling TransactionalSMSApi->send_transac_sms: #{e}"
    end
  end

  def sms_data
    {
      sender: 'MSJ',
      recipient: ENV['PHONE_REMY'],
      content: "Salut, c'est Mon Suivi Justice ;)"
    }
  end
end
