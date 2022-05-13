require 'rails_helper'

RSpec.describe 'Sms Webhook', type: :request do
  let(:path) { sms_webhook_path }
  let(:do_request) { post(path.to_s, params: params) }

  describe 'POST /sms_webhook' do
    before do
      convict = FactoryBot.create(:convict, phone: '+33666666666')
      appointment = FactoryBot.create(:appointment, convict: convict)
      FactoryBot.create(:notification, external_id: '123',
                                       content: 'Youpi', appointment: appointment)
    end

    context 'when the message is soft bounced' do
      let(:params) { { messageId: '123', msg_status: 'softBounces' } }

      it 'enqueues the SMS' do
        expect { do_request }.to have_enqueued_job(SmsDeliveryJob).once
      end
    end

    context 'when the message is not soft bounced' do
      let(:params) { { messageId: '123', msg_status: 'delivered' } }

      it 'does not enqueue the SMS' do
        expect { do_request }.not_to have_enqueued_job(SmsDeliveryJob)
      end
    end
  end
end
