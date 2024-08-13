# spec/queries/notifications/to_reschedule_query_spec.rb
require 'rails_helper'

RSpec.describe Notifications::ToRescheduleQuery do
  include ActiveSupport::Testing::TimeHelpers

  let(:query) { described_class.new }
  let(:today) { Time.zone.today2 }

  describe '#call' do
    context 'when there are valid notifications to be rescheduled' do
      let!(:future_cancelation_notification) do
        create(:notification, state: 'programmed', role: 'cancelation', failed_count: 2)
      end
      let!(:recent_no_show_notification) do
        create(:notification, state: 'programmed', role: 'no_show', failed_count: 1)
      end
      let!(:future_reminder_notification) do
        create(:notification, state: 'programmed', role: 'reminder', failed_count: 0)
      end

      before do
        travel_to 90.days.ago do
          future_cancelation_notification.update!(
            appointment: create(:appointment, state: 'canceled',
                                              slot: create(:slot, date: next_valid_day(date: 95.days.from_now)))
          )
          recent_no_show_notification.update!(
            appointment: create(:appointment, state: 'no_show',
                                              slot: create(:slot, date: next_valid_day(date: 82.days.from_now)))
          )
          future_reminder_notification.update!(
            appointment: create(:appointment, state: 'booked',
                                              slot: create(:slot, date: next_valid_day(date: 100.days.from_now)))
          )
        end
      end

      it 'includes future cancelation notifications' do
        expect(query.call).to include(future_cancelation_notification)
      end

      it 'includes recent no_show notifications (within the last month)' do
        expect(query.call).to include(recent_no_show_notification)
      end

      it 'includes future reminder notifications' do
        expect(query.call).to include(future_reminder_notification)
      end
    end

    context 'when notifications are already scheduled in Sidekiq' do
      let!(:scheduled_notification) do
        create(:notification,
               state: 'programmed',
               role: 'reminder',
               failed_count: 0,
               appointment: create(:appointment, state: 'booked',
                                                 slot: create(:slot, date: next_valid_day(date: 1.day.from_now))))
      end

      before do
        allow_any_instance_of(described_class).to receive(:scheduled_sms_delivery_jobs_notif_ids)
                                              .and_return([scheduled_notification.id])
      end

      it 'excludes notifications that are already scheduled' do
        expect(query.call).not_to include(scheduled_notification)
      end
    end

    context 'when there are no valid notifications to be rescheduled' do
      it 'returns an empty collection' do
        expect(query.call).to be_empty
      end
    end

    context 'with various edge case scenarios' do
      let!(:old_notification) { create(:notification, state: 'programmed', role: 'reminder', failed_count: 3) }
      let!(:future_summon_notification) { create(:notification, state: 'programmed', role: 'summon', failed_count: 1) }
      let!(:old_no_show_notification) { create(:notification, state: 'programmed', role: 'no_show', failed_count: 2) }
      let!(:recent_non_no_show_notification) do
        create(:notification, state: 'programmed', role: 'reminder', failed_count: 2)
      end
      let!(:non_retryable_notification) do
        create(:notification, state: 'programmed', role: 'reminder', failed_count: 5)
      end

      before do
        travel_to 90.days.ago do
          old_notification.update!(
            appointment: create(:appointment, state: 'booked',
                                              slot: create(:slot, date: next_valid_day(date: 30.days.from_now)))
          )
          future_summon_notification.update!(
            appointment: create(:appointment, state: 'booked',
                                              slot: create(:slot, date: next_valid_day(date: 100.days.from_now)))
          )
          old_no_show_notification.update!(
            appointment: create(:appointment, state: 'no_show',
                                              slot: create(:slot, date: next_valid_day(date: 30.days.from_now)))
          )
          recent_non_no_show_notification.update!(
            appointment: create(:appointment, state: 'booked',
                                              slot: create(:slot, date: next_valid_day(date: 70.days.from_now)))
          )
          non_retryable_notification.update!(
            appointment: create(:appointment, state: 'booked',
                                              slot: create(:slot, date: next_valid_day(date: 91.days.from_now)))
          )
        end
      end

      it 'includes future summon notifications' do
        expect(query.call).to include(future_summon_notification)
      end

      it 'excludes notifications more than 1 month old' do
        expect(query.call).not_to include(old_notification)
      end

      it 'excludes no_show notifications more than 1 month old' do
        expect(query.call).not_to include(old_no_show_notification)
      end

      it 'excludes recent non-no_show notifications in the past' do
        expect(query.call).not_to include(recent_non_no_show_notification)
      end

      it 'excludes non-retryable notifications (failed_count > 4)' do
        expect(query.call).not_to include(non_retryable_notification)
      end
    end

    context 'with notifications in different states and roles' do
      let!(:created_notification) do
        create(:notification,
               state: 'created', role: 'reminder', failed_count: 0,
               appointment: create(:appointment, state: 'booked',
                                                 slot: create(:slot, date: next_valid_day(date: 1.day.from_now))))
      end

      let!(:sent_notification) do
        create(:notification,
               state: 'sent', role: 'reminder', failed_count: 0, external_id: '123',
               appointment: create(:appointment, state: 'booked',
                                                 slot: create(:slot, date: next_valid_day(date: 1.day.from_now))))
      end

      let!(:future_reschedule_notification) do
        create(:notification,
               state: 'programmed', role: 'reschedule', failed_count: 0,
               appointment: create(:appointment, state: 'booked',
                                                 slot: create(:slot, date: next_valid_day(date: 1.day.from_now))))
      end

      it 'excludes notifications not in programmed state' do
        expect(query.call).not_to include(created_notification, sent_notification)
      end

      it 'includes future reschedule notifications' do
        expect(query.call).to include(future_reschedule_notification)
      end
    end
  end
end
