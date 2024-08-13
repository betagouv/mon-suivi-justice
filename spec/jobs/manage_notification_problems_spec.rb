# spec/jobs/manage_notification_problems_spec.rb
require 'rails_helper'

RSpec.describe ManageNotificationProblems, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:job) { described_class.new }
    let(:to_reschedule_query) { instance_double(Notifications::ToRescheduleQuery) }
    let(:to_be_marked_as_failed_query) { instance_double(Notifications::ToBeMarkedAsFailedQuery) }

    before do
      allow(Notifications::ToRescheduleQuery).to receive(:new).and_return(to_reschedule_query)
      allow(Notifications::ToBeMarkedAsFailedQuery).to receive(:new).and_return(to_be_marked_as_failed_query)
    end

    context 'when there are notifications to reschedule and mark as failed' do
      let(:notification_to_reschedule) { create(:notification, state: 'programmed') }
      let(:notification_to_fail) { create(:notification, state: 'programmed') }

      before do
        allow(to_reschedule_query).to receive(:call).and_return([notification_to_reschedule])
        allow(to_be_marked_as_failed_query).to receive(:call).and_return([notification_to_fail])
      end

      it 'both reschedules and marks as failed' do
        expect(SmsDeliveryJob).to receive(:perform_later).with(notification_to_reschedule.id)
        expect(notification_to_fail).to receive(:handle_unsent!)
        job.perform
      end

      it 'informs admins' do
        expect(AdminMailer).to receive(:notifications_problems).with([notification_to_reschedule.id],
                                                                     [notification_to_fail.id])
                                                               .and_return(double(deliver_later: true))
        job.perform
      end
    end

    context 'when there are no notifications to process' do
      before do
        allow(to_reschedule_query).to receive(:call).and_return([])
        allow(to_be_marked_as_failed_query).to receive(:call).and_return([])
      end

      it 'does not send any admin email' do
        expect(AdminMailer).not_to receive(:notifications_problems)
        job.perform
      end
    end

    context 'when rescheduling a reminder notification' do
      let(:reminder_notification) { create(:notification, state: 'programmed', role: 'reminder') }

      before do
        allow(to_reschedule_query).to receive(:call).and_return([reminder_notification])
        allow(to_be_marked_as_failed_query).to receive(:call).and_return([])
        allow(reminder_notification).to receive(:delivery_time).and_return(1.day.from_now)
      end

      it 'schedules the reminder with the correct delivery time' do
        expect(SmsDeliveryJob).to receive(:set).with(wait_until: reminder_notification.delivery_time)
                                               .and_return(SmsDeliveryJob)
        expect(SmsDeliveryJob).to receive(:perform_later).with(reminder_notification.id)
        job.perform
      end
    end
  end
end
