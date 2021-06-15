require 'rails_helper'

RSpec.describe SendinblueAdapter do
  describe 'send_sms' do
    it 'calls Sendinblue API' do
      sib_api_mock = instance_double(SibApiV3Sdk::TransactionalSMSApi)
      allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(sib_api_mock)
      expect(sib_api_mock).to receive(:send_transac_sms)

      SendinblueAdapter.new.send_sms
    end
  end
end
