require 'rails_helper'

RSpec.describe ManageNotificationProblems, type: :job do
  include ActiveJob::TestHelper

  # Check high failure

  describe '#perform' do
    let(:past_slot) { create(:slot, date: next_valid_day(date: Time.zone.now + 1.day)) }
    let(:future_slot) { create(:slot, date: next_valid_day(date: Time.zone.now + 20.day)) }
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
      allow_any_instance_of(ManageNotificationProblems)
        .to receive(:scheduled_sms_delivery_jobs_notif_ids)
        .and_return([other_notification3.id])

      Timecop.freeze(Time.zone.now + 10.days)
    end

    after do
      Timecop.return
    end

    context 'when there are notifications to handle' do
      let!(:notification_to_reschedule1) do
        create(:notification, appointment: appointment_for_future_slot, state: 'programmed', role: 'reminder')
      end
      let!(:notification_to_reschedule2) do
        create(:notification, appointment: appointment_for_future_slot, state: 'programmed', role: 'summon')
      end
      let!(:notification_to_reschedule3) do
        build(:notification, appointment: appointment_for_future_slot, state: 'sent', role: 'no_show', external_id: nil)
        .tap { |n| n.save(validate: false) }
      end

      let!(:stucked_notification1) do
        create(:notification, appointment: appointment_for_past_slot, state: 'programmed', role: 'reminder', id: 100)
      end

      let!(:stucked_notification2) do
        create(:notification, appointment: appointment_for_past_slot, state: 'programmed', role: 'reminder')
      end
      let!(:failed_notification) do
        create(:notification, appointment: appointment_for_future_slot, state: 'programmed', role: 'cancelation',
                              failed_count: 5)
      end
      let!(:registered_failed_notification) do
        create(:notification, appointment: appointment_for_future_slot, state: 'failed', role: 'cancelation',
                              failed_count: 5)
      end

      it 'reschedules the correct notifications' do
        expect do
          described_class.perform_now
        end.to have_enqueued_job(SmsDeliveryJob).exactly(3).times

        expect(SmsDeliveryJob).to have_been_enqueued.with(notification_to_reschedule1.id)
        expect(SmsDeliveryJob).to have_been_enqueued.with(notification_to_reschedule2.id)
        expect(SmsDeliveryJob).to have_been_enqueued.with(notification_to_reschedule3.id)
      end

      it 'sets stucked notifications to failed' do
        described_class.perform_now
        expect(stucked_notification1.reload.state).to eq('failed')
        expect(stucked_notification2.reload.state).to eq('failed')
        expect(failed_notification.reload.state).to eq('failed')
        expect(notification_to_reschedule1.reload.state).to eq('programmed')
        expect(notification_to_reschedule2.reload.state).to eq('programmed')
        expect(notification_to_reschedule3.reload.state).to eq('sent')
        expect(other_notification1.reload.state).to eq('unsent')
        expect(other_notification2.reload.state).to eq('canceled')
        expect(other_notification3.reload.state).to eq('programmed')
      end

      it 'sends an email to admins with correct arguments' do
        expect do
          described_class.perform_now
        end.to have_enqueued_mail(AdminMailer, :notifications_problems)
          .with(match_array([notification_to_reschedule1.id, notification_to_reschedule2.id,
                             notification_to_reschedule3.id]),
                match_array([stucked_notification1.id, stucked_notification2.id, failed_notification.id]))
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
