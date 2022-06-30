# rails r scripts/sendinblue/get_infos_account.rb

# Load the gem
require 'sib-api-v3-sdk'

# Setup authorization
SibApiV3Sdk.configure do |config|
  # Configure API key authorization: api-key
  config.api_key['api-key'] = ENV['SIB_API_KEY']
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  #config.api_key_prefix['api-key'] = 'Bearer'

  # Configure API key authorization: partner-key
  config.api_key['partner-key'] = ENV['SIB_API_KEY']
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  #config.api_key_prefix['partner-key'] = 'Bearer'
end

api_instance = SibApiV3Sdk::AccountApi.new

begin
  #Get your account information, plan and credits details
  result = api_instance.get_account
  pp result
rescue SibApiV3Sdk::ApiError => e
  puts "Exception when calling AccountApi->get_account: #{e}"
end
