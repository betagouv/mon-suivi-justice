require 'rails_helper'

RSpec.describe SmsScheduleJob, type: :job do
  describe '#perform' do
    let(:current_time) { Time.current }

    let!(:notification_ready) { create(:notification, delivery_time: current_time, state: 'created') }

    let!(:notification_past) { create(:notification, delivery_time: 2.hours.ago, state: 'created') }

    let!(:notification_future) { create(:notification, delivery_time: 2.hours.from_now, state: 'created') }

    let!(:notification_sent) { create(:notification, delivery_time: current_time, state: 'sent', external_id: '123') }

    it 'appelle program_now uniquement sur les notifications prêtes à être envoyées' do
      expect(Notification).to receive(:ready_to_send).and_return([notification_ready])
      expect(notification_ready).to receive(:program_now)
      expect(notification_past).not_to receive(:program_now)
      expect(notification_future).not_to receive(:program_now)
      expect(notification_sent).not_to receive(:program_now)
      described_class.perform_now
    end
  end
end
