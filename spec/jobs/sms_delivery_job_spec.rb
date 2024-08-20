require 'rails_helper'

RSpec.describe SmsDeliveryJob, type: :job do
  describe '#perform' do
    let(:tested_method) { SmsDeliveryJob.perform_now(notification.id) }
    let(:delivery_service_dbl) { instance_double SmsDeliveryService }
    let(:notification) { create(:notification) }

    before do
      allow(SmsDeliveryService).to receive(:new).with(notification).and_return delivery_service_dbl
      allow(delivery_service_dbl).to receive(:send_sms)
      tested_method
    end

    it 'calls SmsDeliveryService' do
      expect(SmsDeliveryService).to have_received(:new).with(notification).once
    end

    it 'send sms' do
      expect(delivery_service_dbl).to have_received(:send_sms).once
    end
  end
end
