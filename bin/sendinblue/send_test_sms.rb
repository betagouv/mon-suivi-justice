# rails r bin/sendinblue/send_test_sms.rb

require 'sib-api-v3-sdk'

SibApiV3Sdk.configure do |config|
  config.api_key['api-key'] = ENV['SIB_API_KEY']
  config.api_key['partner-key'] = ENV['SIB_API_KEY']
end

api_instance = SibApiV3Sdk::TransactionalSMSApi.new

sms = SibApiV3Sdk::SendTransacSms.new(
  sender: 'MSJ',
  recipient: ENV['PHONE_REMY'],
  content: "SMS de test envoyé avec un script"
)

# recipient: phone number with country code, ex: '+33607070707'

begin
  result = api_instance.send_transac_sms(sms)
  p result
rescue SibApiV3Sdk::ApiError => e
  puts "Exception when calling TransactionalSMSApi->send_transac_sms: #{e}"
end
