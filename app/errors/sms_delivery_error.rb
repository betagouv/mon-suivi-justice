class SmsDeliveryError < StandardError
  attr_reader :status_code, :error_message

  def initialize(status_code, error_message)
    @status_code = status_code
    @error_message = error_message
    super("Erreur d'envoi SMS (Code: #{status_code}): #{error_message}")
  end
end