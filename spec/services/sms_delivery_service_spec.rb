require 'rails_helper'

RSpec.describe SmsDeliveryService do
  let(:convict) { create(:convict) }
  let(:appointment) { create(:appointment, convict:) }
  let(:notification) { create(:notification, appointment:, state: 'programmed') }
  let(:service) { described_class.new(notification) }

  describe '#send_sms' do
    context 'when SMS cannot be sent' do
      it 'does not call LinkMobilityAdapter if notification is already sent' do
        notification.update(state: 'sent', external_id: 'some_id')
        expect(LinkMobilityAdapter).not_to receive(:new)
        service.send_sms
      end

      it 'does not call LinkMobilityAdapter if convict cannot receive SMS' do
        allow_any_instance_of(Convict).to receive(:can_receive_sms?).and_return(false)
        expect(LinkMobilityAdapter).not_to receive(:new)
        service.send_sms
        expect(notification.reload.state).to eq('unsent')
      end
    end

    context 'when SMS can be sent' do
      let(:adapter) { instance_double('LinkMobilityAdapter') }

      before do
        allow_any_instance_of(Convict).to receive(:can_receive_sms?).and_return(true)
        allow(LinkMobilityAdapter).to receive(:new).with(notification).and_return(adapter)
      end

      it 'calls LinkMobilityAdapter if notification is programmed and convict has a phone number' do
        expect(adapter).to receive(:send_sms).and_return(SmsApiResponse.new(success: true, external_id: 'some_id',
                                                                            code: nil, message: nil,
                                                                            retry_if_failed: nil))
        service.send_sms
      end

      context 'when LinkMobilityAdapter response includes external_id' do
        it 'updates the notification with the external_id and marks it as sent' do
          allow(adapter).to receive(:send_sms).and_return(SmsApiResponse.new(success: true, external_id: '123456',
                                                                             should_raise_error: nil))
          service.send_sms
          notification.reload
          expect(notification.external_id).to eq('123456')
          expect(notification.state).to eq('sent')
        end
      end

      context 'when LinkMobilityAdapter response is a failure' do
        before do
          allow(adapter).to receive(:send_sms).and_return(SmsApiResponse.new(success: false, external_id: nil,
                                                                             should_raise_error: false))
        end

        context 'when notification has already failed 5 times' do
          it 'marks the notification as failed' do
            notification.update(failed_count: 5)
            service.send_sms
            expect(notification.reload.state).to eq('failed')
          end
        end

        context 'when notification has failed less than 5 times' do
          it 'increments the failure count and schedules a new attempt' do
            expect do
              service.send_sms
            end.to change { notification.reload.failed_count }.by(1)

            expect(SmsDeliveryJob).to have_been_enqueued.with(notification.id)

            enqueued_job = ActiveJob::Base.queue_adapter.enqueued_jobs.last
            expect(enqueued_job['job_class']).to eq('SmsDeliveryJob')
            expect(enqueued_job['arguments']).to eq([notification.id])
            expect(enqueued_job[:at]).to be_within(1.minute).of(5.minutes.from_now.to_f)
          end
        end
      end

      context 'when LinkMobilityAdapter response is a success' do
        before do
          allow(adapter).to receive(:send_sms).and_return(SmsApiResponse.new(success: true, external_id: 'some_id',
                                                                             should_raise_error: nil))
        end

        it 'marks the notification as sent' do
          service.send_sms
          expect(notification.reload.state).to eq('sent')
        end

        it 'retries marking as sent if it fails initially' do
          call_count = 0
          allow_any_instance_of(Notification).to receive(:mark_as_sent!) do
            call_count += 1
            raise StandardError if call_count == 1

            true
          end
          expect(service).to receive(:sleep).with(0.5).once
          service.send_sms
          expect(call_count).to eq(2)
        end

        it 'raises an error after 5 failed attempts to mark as sent' do
          allow_any_instance_of(Notification).to receive(:mark_as_sent!).and_raise(StandardError)
          expect(service).to receive(:sleep).with(0.5).exactly(4).times
          expect { service.send_sms }.to raise_error(StandardError)
        end
      end
    end
  end
end
