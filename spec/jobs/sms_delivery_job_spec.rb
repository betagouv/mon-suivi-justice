require 'rails_helper'

RSpec.describe SmsDeliveryJob, type: :job do
  let(:notification) { create :notification }

  describe '#perform_later' do
    let(:tested_method) { SmsDeliveryJob.perform_later(notification) }

    it 'queues the job' do
      tested_method
      expect(SmsDeliveryJob).to have_been_enqueued.once.with(notification)
    end
  end

  describe '#perform' do
    let(:tested_method) { SmsDeliveryJob.new.perform(notification) }
    let(:adapter_dbl) { instance_double SendinblueAdapter, send_sms: true }

    before do
      allow(SendinblueAdapter).to receive(:new).and_return adapter_dbl
      tested_method
    end

    it 'instantiates SendinblueAdapter' do
      expect(SendinblueAdapter).to have_received(:new).once
    end
    it 'send sms' do
      expect(adapter_dbl).to have_received(:send_sms).once.with(notification, resent: false)
    end
    it 'get sms events' do
      expect(GetSmsStatusJob).to have_been_enqueued.once.with(notification.id)
    end
  end
end
