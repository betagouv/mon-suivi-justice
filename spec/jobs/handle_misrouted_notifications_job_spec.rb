require 'rails_helper'

RSpec.describe HandleMisroutedNotificationsJob, type: :job do
  describe '#perform' do
    let!(:notification1) do
      create(:notification, target_phone: '+33611111111', response_code: '16', state: 'failed',
                            delivery_time: 1.day.ago)
    end
    let!(:notification2) do
      create(:notification, target_phone: '+33622222222', response_code: '16', state: 'failed',
                            delivery_time: 1.day.ago)
    end
    let!(:notification3) do
      create(:notification, target_phone: '+33611111111', response_code: '16', state: 'failed',
                            delivery_time: 1.day.ago)
    end
    let!(:notification4) do
      create(:notification, target_phone: '+33633333333', response_code: '16', state: 'failed',
                            delivery_time: 3.days.ago)
    end
    let!(:notification5) do
      create(:notification, target_phone: '+33633333333', response_code: '0', state: 'sent', delivery_time: 1.day.ago,
                            external_id: '1234567890')
    end

    it 'envoie un email avec les numéros de téléphone uniques à rerouter' do
      expect do
        described_class.perform_now
      end.to have_enqueued_mail(AdminMailer, :warn_link_mobility_for_misrouted_notifications)
        .with(params: { phones: ['+33611111111', '+33622222222'] }, args: [])
    end
  end
end
