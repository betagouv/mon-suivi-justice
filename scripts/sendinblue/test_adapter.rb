# rails r bin/sendinblue/test_adapter.rb

require_relative '../../app/services/sendinblue_adapter.rb'

SendinblueAdapter.new.send_sms
