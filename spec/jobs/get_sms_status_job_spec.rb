require 'rails_helper'

RSpec.describe GetSmsStatusJob, type: :job do
  describe '#perform' do
    it 'get sms events' do
      notification = create :notification
      adapter_dbl = instance_double SendinblueAdapter, get_sms_status: true
      allow(SendinblueAdapter).to receive(:new).and_return adapter_dbl

      GetSmsStatusJob.perform_now(notification.id)

      expect(adapter_dbl).to have_received(:get_sms_status).once.with(notification)
    end
  end
end
