require 'rails_helper'

RSpec.describe SmsDeliveryJob, type: :job do
  context 'with a phone number' do
    let(:convict) { create :convict, phone: '+33606060607' }
    let(:appointment) { create :appointment, convict: }
    let(:notification) { create :notification, state: :programmed, appointment: }

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

      # TODO: rework the notification status system with new provider
      # it 'get sms events' do
      #   expect(GetSmsStatusJob).to have_been_enqueued.once.with(notification.id)
      # end
    end
  end

  context 'without a phone number' do
    let(:convict) { create :convict, phone: '', no_phone: true }
    let(:appointment) { create :appointment, convict: }
    let(:notification) { create :notification, state: :programmed, appointment: }

    describe '#perform' do
      let(:tested_method) { SmsDeliveryJob.perform_now(notification.id) }
      let(:adapter_dbl) { instance_double LinkMobilityAdapter, send_sms: true }

      before do
        allow(LinkMobilityAdapter).to receive(:new).and_return adapter_dbl
        tested_method
      end

      it "don't instantiates LinkMobilityAdapter" do
        expect(LinkMobilityAdapter).not_to have_received(:new)
      end

      it "don't send sms" do
        expect(adapter_dbl).not_to have_received(:send_sms)
      end

      it 'changes status to unsent for programmed notification' do
        expect(notification.reload.state).to eq('unsent')
      end
      # TODO: rework the notification status system with new provider
      # it "don't get sms events" do
      #   expect(GetSmsStatusJob).not_to have_been_enqueued
      # end
    end
  end
end
