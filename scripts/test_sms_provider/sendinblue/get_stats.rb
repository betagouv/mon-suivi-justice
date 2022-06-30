# rails r scripts/sendinblue/get_stats.rb
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
  # phone_number: ENV['PHONE_REMY'] # String | Filter the report for a specific phone number
    start_date: '2021-08-27', # String | Mandatory if endDate is used. Starting date (YYYY-MM-DD) of the report
    end_date: '2021-08-27', # String | Mandatory if startDate is used. Ending date (YYYY-MM-DD) of the report
}

begin
  # Get all SMS activity for one phone number
  result = api_instance.get_sms_events(opts)
  # pp result
  # Filter by message_id
  events = result.events.select { |event| event.message_id == '8124693649388468' }
  pp events
  # event_arr = events.map(&:event)
  # p event_arr
  # p event_arr.include?('delivered')
  # pp events.pluck(:event)
rescue SibApiV3Sdk::ApiError => e
  puts "Exception when calling TransactionalSMSApi->get_sms_events: #{e}"
end
