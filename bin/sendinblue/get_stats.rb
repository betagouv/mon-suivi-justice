# rails r bin/sendinblue/get_stats.rb
# docs: https://github.com/sendinblue/APIv3-ruby-library/blob/master/docs/TransactionalSMSApi.md#get_transac_sms_report

require 'sib-api-v3-sdk'

SibApiV3Sdk.configure do |config|
  config.api_key['api-key'] = ENV['SIB_API_KEY']
  config.api_key['partner-key'] = ENV['SIB_API_KEY']
end

api_instance = SibApiV3Sdk::TransactionalSMSApi.new

# opts = {
#   limit: 50, # Integer | Number of documents per page
#   start_date: 'start_date_example', # String | Mandatory if endDate is used. Starting date (YYYY-MM-DD) of the report
#   end_date: 'end_date_example', # String | Mandatory if startDate is used. Ending date (YYYY-MM-DD) of the report
#   offset: 0, # Integer | Index of the first document of the page
#   days: 789, # Integer | Number of days in the past including today (positive integer). Not compatible with 'startDate' and 'endDate'
#   phone_number: 'phone_number_example', # String | Filter the report for a specific phone number
#   event: 'event_example', # String | Filter the report for specific events
#   tags: 'tags_example', # String | Filter the report for specific tags passed as a serialized urlencoded array
#   sort: 'desc' # String | Sort the results in the ascending/descending order of record creation. Default order is **descending** if `sort` is not passed
# }

opts = {
  phone_number: ENV['PHONE_REMY'] # String | Filter the report for a specific phone number
}

begin
  #Get all your SMS activity (unaggregated events)
  result = api_instance.get_sms_events(opts)
  pp result
rescue SibApiV3Sdk::ApiError => e
  puts "Exception when calling TransactionalSMSApi->get_sms_events: #{e}"
end
