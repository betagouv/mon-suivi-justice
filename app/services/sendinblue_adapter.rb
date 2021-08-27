class SendinblueAdapter
  def initialize
    SibApiV3Sdk.configure do |config|
      config.api_key['api-key'] = ENV['SIB_API_KEY']
      config.api_key['partner-key'] = ENV['SIB_API_KEY']
    end

    @client = SibApiV3Sdk::TransactionalSMSApi.new
  end

  def send_sms(notification)
    sms_data = format_data(notification)
    sms = SibApiV3Sdk::SendTransacSms.new(sms_data)

    begin
      result = @client.send_transac_sms(sms)
      notification.update(external_id: result.message_id)
    rescue SibApiV3Sdk::ApiError => e
      puts "Exception when calling TransactionalSMSApi->send_transac_sms: #{e}"
    end
  end

  def format_data(notification)
    {
      sender: ENV['SMS_SENDER'],
      recipient: notification.appointment.convict.phone,
      content: notification.content
    }
  end
end
