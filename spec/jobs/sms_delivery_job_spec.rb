require 'rails_helper'

RSpec.describe SmsDeliveryJob, type: :job do
  let(:convict) { create :convict, phone: '+33606060606' }
  let(:appointment) { create :appointment, convict: convict }
  let(:notification) { create :notification, appointment: appointment }

  context 'with a phone number' do
    describe '#perform' do
      let(:tested_method) { SmsDeliveryJob.perform_now(notification.id) }
      let(:adapter_dbl) { instance_double LinkMobilityAdapter, send_sms: true }

      before do
        allow(LinkMobilityAdapter).to receive(:new).and_return adapter_dbl
        tested_method
      end

      it 'instantiates LinkMobilityAdapter' do
        expect(LinkMobilityAdapter).to have_received(:new).once
      end

      it 'send sms' do
        expect(adapter_dbl).to have_received(:send_sms).once.with(notification)
      end

      xit 'get sms events' do
        expect(GetSmsStatusJob).to have_been_enqueued.once.with(notification.id)
      end
    end
  end

  xcontext 'without a phone number' do
    describe '#perform' do
      let(:adapter_dbl) { instance_double LinkMobilityAdapter, send_sms: true }

      before do
        convict.update(phone: '')
        allow(LinkMobilityAdapter).to receive(:new).and_return adapter_dbl
        SmsDeliveryJob.perform_now(notification.id)
      end

      it "don't instantiates LinkMobilityAdapter" do
        expect(LinkMobilityAdapter).not_to have_received(:new)
      end

      it "don't send sms" do
        expect(adapter_dbl).not_to have_received(:send_sms)
      end

      xit "don't get sms events" do
        expect(GetSmsStatusJob).not_to have_been_enqueued
      end
    end
  end
end
