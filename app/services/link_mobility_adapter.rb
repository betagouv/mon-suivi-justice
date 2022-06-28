# Documentation in a PDF named "Netsize Implementation Guide, REST API - SMS.pdf"
class LinkMobilityAdapter
  def initialize
    @client = Faraday.new(
      url: 'https://europe.ipx.com'
    ) do |conn|
      conn.request :authorization, :basic, ENV.fetch('LM_ACCOUNT', nil), ENV.fetch('LM_PWD', nil)
    end
  end

  def send_sms(notification)
    sms_data = format_data(notification)

    response = @client.post('/restapi/v1/sms/send') do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
      req.body = URI.encode_www_form(sms_data)
    end

    set_notification_external_id(notification, response)
  end

  def format_data(notification)
    {
      destinationAddress: notification.appointment.convict.phone,
      messageText: notification.content,
      originatorTON: 1,
      originatingAddress: ENV.fetch('SMS_SENDER', nil),
      maxConcatenatedMessages: 10
    }
  end

  def set_notification_external_id(notification, response)
    response_hash = JSON.parse(response.body)

    if (response_hash['responseCode']).zero?
      notification.update(external_id: response_hash['messageIds'].first)
    else
      puts "Error when sending SMS: #{response_hash['responseMessage']}"
    end
  end

  # def get_sms_status(notification)
  #
  # end
end
