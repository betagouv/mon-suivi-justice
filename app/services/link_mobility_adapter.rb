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

    mark_as_sent_if_success(notification, response)
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

  def mark_as_sent_if_success(notification, response)
    response_hash = JSON.parse(response.body)

    raise SmsDeliveryError.new(500, response_hash['responseMessage']) unless (response_hash['responseCode']).zero?

    notification.transaction do
      notification.update(external_id: response_hash['messageIds'].first)
      notification.mark_as_sent if notification.programmed?
    end
  end

  # def get_sms_status(notification)
  #
  # end
end
