require 'rails_helper'

RSpec.describe ManageUnsentNotification, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:past_slot) { create(:slot, date: Time.zone.now + 1.day) }
    let(:future_slot) { create(:slot, date: Time.zone.now + 3.day) }
    let(:appointment_for_past_slot) { create(:appointment, slot: past_slot, state: 'booked') }
    let(:appointment_for_future_slot) { create(:appointment, slot: future_slot, state: 'booked') }

    let!(:other_notification1) do
      create(:notification, appointment: appointment_for_past_slot, state: 'unsent')
    end
    let!(:other_notification2) do
      create(:notification, appointment: appointment_for_future_slot, state: 'canceled')
    end
    let!(:other_notification3) do
      create(:notification, appointment: appointment_for_future_slot, state: 'programmed', role: 'reminder')
    end

    before do
      allow_any_instance_of(ManageUnsentNotification)
        .to receive(:scheduled_sms_delivery_jobs_notif_ids)
        .and_return([other_notification3.id])

      Timecop.freeze(Time.zone.now + 2.days)
    end

    after do
      Timecop.return
    end

    context 'when there are notifications to handle' do
      let!(:notification_to_reschedule) do
        create(:notification, appointment: appointment_for_future_slot, state: 'programmed', role: 'reminder')
      end

      let!(:unsent_notification1) do
        create(:notification, appointment: appointment_for_past_slot, state: 'programmed', role: 'reminder')
      end

      let!(:unsent_notification2) do
        create(:notification, appointment: appointment_for_past_slot, state: 'programmed', role: 'reminder')
      end

      it 'reschedules the correct notifications' do
        expect do
          described_class.perform_now
        end.to have_enqueued_job(SmsDeliveryJob).with(notification_to_reschedule.id)
      end

      it 'sets unsent notifications to failed' do
        described_class.perform_now
        expect(unsent_notification1.reload.state).to eq('failed')
        expect(unsent_notification2.reload.state).to eq('failed')
        expect(notification_to_reschedule.reload.state).to eq('programmed')
        expect(other_notification1.reload.state).to eq('unsent')
      end

      context 'when there are notifications to handle' do
        it 'sends an email to admins with correct arguments' do
          expect do
            described_class.perform_now
          end.to have_enqueued_mail(AdminMailer, :notifications_problems)
            .with(match_array([notification_to_reschedule.id]),
                  match_array([unsent_notification1.id, unsent_notification2.id]))
        end
      end
    end

    context 'when there are no notifications to handle' do
      it 'does not send an email to admins' do
        expect do
          described_class.perform_now
        end.not_to have_enqueued_mail(AdminMailer, :notifications_problems)
      end
    end
  end
end
