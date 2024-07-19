# Documentation in a PDF named "Netsize Implementation Guide, REST API - SMS.pdf"
class LinkMobilityAdapter
  attr_reader :notification

  def initialize(notification)
    @notification = notification
    @client = Faraday.new(
      url: 'https://europe.ipx.com'
    ) do |conn|
      conn.request :authorization, :basic, ENV.fetch('LM_ACCOUNT', nil), ENV.fetch('LM_PWD', nil)
    end
  end

  def send_sms
    response = @client.post('/restapi/v1/sms/send') do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
      req.body = URI.encode_www_form(sms_data)
    end

    parsed_response = JSON.parse(response.body)

    { success: parsed_response['responseCode'].zero?, external_id: parsed_response['messageIds'].first }
  end

  private

  def sms_data
    {
      destinationAddress: notification.appointment.convict.phone,
      messageText: notification.content,
      originatorTON: 1,
      originatingAddress: ENV.fetch('SMS_SENDER', nil),
      maxConcatenatedMessages: 10
    }
  end
end
