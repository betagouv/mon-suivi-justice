# rails r bin/sendinblue/get_stats.rb
# docs: https://github.com/sendinblue/APIv3-ruby-library/blob/master/docs/TransactionalSMSApi.md#get_transac_sms_report

require 'sib-api-v3-sdk'

SibApiV3Sdk.configure do |config|
  config.api_key['api-key'] = ENV['SIB_API_KEY']
  config.api_key['partner-key'] = ENV['SIB_API_KEY']
end

api_instance = SibApiV3Sdk::TransactionalSMSApi.new

opts = {
  start_date: 'start_date_example', # String | Mandatory if endDate is used. Starting date (YYYY-MM-DD) of the report
  end_date: 'end_date_example', # String | Mandatory if startDate is used. Ending date (YYYY-MM-DD) of the report
  days: 789, # Integer | Number of days in the past including today (positive integer). Not compatible with 'startDate' and 'endDate'
  tag: 'tag_example', # String | Filter on a tag
  sort: 'desc' # String | Sort the results in the ascending/descending order of record creation. Default order is **descending** if `sort` is not passed
}

begin
  #Get your SMS activity aggregated per day
  result = api_instance.get_transac_sms_report()
  pp result
rescue SibApiV3Sdk::ApiError => e
  puts "Exception when calling TransactionalSMSApi->get_transac_sms_report: #{e}"
end
