require 'rails_helper'

RSpec.describe SmsDeliveryService do
  let(:notification) { create(:notification, state: 'programmed') }
  let(:service) { described_class.new(notification) }
  let(:link_mobility_adapter) { instance_double(LinkMobilityAdapter) }
  let(:response) { double('response') }

  before do
    allow(LinkMobilityAdapter).to receive(:new).and_return(link_mobility_adapter)
    allow(link_mobility_adapter).to receive(:send_sms).and_return(response)
  end

  describe '#send_sms' do
    context 'when notification is in created state' do
      before { notification.update(state: 'created') }

      it 'raises an error' do
        expect do
          service.send_sms
        end.to raise_error(RuntimeError, /Notification \(id: #{notification.id}\) state still created/)
      end
    end

    context 'when notification cannot be sent' do
      before { allow(notification).to receive(:can_be_sent?).and_return(false) }

      it 'calls handle_unsent!' do
        expect(notification).to receive(:handle_unsent!)
        service.send_sms
      end
    end

    context 'when notification can be sent' do
      before do
        allow(notification).to receive(:can_be_sent?).and_return(true)
        allow(response).to receive(:external_id).and_return('123')
        allow(response).to receive(:success).and_return(true)
      end

      it 'updates notification with external_id' do
        service.send_sms
        expect(notification.reload.external_id).to eq('123')
      end

      it 'marks notification as sent on success' do
        service.send_sms
        expect(notification.reload.state).to eq('sent')
      end

      context 'when sending fails' do
        before do
          allow(response).to receive(:success).and_return(false)
          allow(response).to receive(:retry_if_failed?).and_return(false)
        end

        it 'increments failed_count' do
          expect { service.send_sms }.to change { notification.reload.failed_count }.by(1)
        end

        it 'marks notification as failed' do
          service.send_sms
          expect(notification.reload.state).to eq('failed')
        end

        context 'when retry is possible' do
          before do
            allow(response).to receive(:retry_if_failed?).and_return(true)
            allow(response).to receive(:code).and_return('500')
            allow(response).to receive(:message).and_return('Server Error')
          end

          it 'raises SmsDeliveryError' do
            expect { service.send_sms }.to raise_error(SmsDeliveryError)
          end
        end
      end
    end
  end
end
