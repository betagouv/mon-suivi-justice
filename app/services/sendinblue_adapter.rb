class SendinblueAdapter
  def initialize
    SibApiV3Sdk.configure do |config|
      config.api_key['api-key'] = ENV.fetch('SIB_API_KEY', nil)
      config.api_key['partner-key'] = ENV.fetch('SIB_API_KEY', nil)
    end

    @client = SibApiV3Sdk::TransactionalSMSApi.new
  end

  def send_sms(notification)
    sms_data = format_data(notification)
    sms = SibApiV3Sdk::SendTransacSms.new(sms_data)

    result = @client.send_transac_sms(sms)
    notification.update(external_id: result.message_id)
  end

  def format_data(notification)
    {
      sender: ENV.fetch('SMS_SENDER', nil),
      recipient: notification.appointment.convict.phone,
      content: notification.content
    }
  end

  def get_sms_status(notification)
    phone = notification.appointment.convict.phone

    begin
      result = @client.get_sms_events({ phone_number: phone })
      set_notification_state(notification, result)
    rescue SibApiV3Sdk::ApiError => e
      puts "Exception when calling TransactionalSMSApi -> get_sms_events: #{e}"
    end
  end

  def set_notification_state(notification, sms_data)
    return if sms_data.events.nil?
    return if sms_data.events.empty?

    events = sms_data.events
                     .select { |event| event.message_id == notification.external_id }
                     .map(&:event)

    notification.receive! if events.include?('delivered')
    notification.failed_send! if events.intersect?(%w[hardBounces softBounces])
  end
end
