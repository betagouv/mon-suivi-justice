# spec/jobs/manage_notification_problems_spec.rb
require 'rails_helper'

RSpec.describe ManageNotificationProblems, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:job) { described_class.new }
    let(:to_be_marked_as_failed_query) { instance_double(Notifications::ToBeMarkedAsFailedQuery) }

    before do
      allow(Notifications::ToBeMarkedAsFailedQuery).to receive(:new).and_return(to_be_marked_as_failed_query)
    end

    context 'when there are notifications to mark as failed' do
      let(:notification_to_fail) { create(:notification, state: 'programmed') }

      before do
        allow(to_be_marked_as_failed_query).to receive(:call).and_return([notification_to_fail])
      end

      it 'marks as failed' do
        expect(notification_to_fail).to receive(:handle_unsent!)
        job.perform
      end

      it 'informs admins' do
        expect(AdminMailer).to receive(:notifications_problems).with([notification_to_fail.id])
                                                              .and_return(double(deliver_later: true))
        job.perform
      end
    end

    context 'when there are no notifications to process' do
      before do
        allow(to_be_marked_as_failed_query).to receive(:call).and_return([])
      end

      it 'does not send any admin email' do
        expect(AdminMailer).not_to receive(:notifications_problems)
        job.perform
      end
    end
  end
end
