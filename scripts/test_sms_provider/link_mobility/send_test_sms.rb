# rails r scripts/test_sms_provider/link_mobility/send_test_sms.rb

require 'faraday'
require 'faraday/net_http'
require 'uri'
Faraday.default_adapter = :net_http

client = Faraday.new(
  url: 'https://europe.ipx.com',
) do |conn|
  conn.request :authorization, :basic, ENV['LM_ACCOUNT'], ENV['LM_PWD']
end

data = {
  destinationAddress: '33600000000',
  messageText: 'SMS test link_mobility 4',
  originatorTON: 1,
  originatingAddress: 'JUSTICETEST'
}

response = client.post('/restapi/v1/sms/send') do |req|
  req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
  req.body = URI.encode_www_form(data)
end

p response.body
