# spec/queries/notifications/to_be_marked_as_failed_query_spec.rb
require 'rails_helper'

RSpec.describe Notifications::ToBeMarkedAsFailedQuery do
  include ActiveSupport::Testing::TimeHelpers

  let(:query) { described_class.new }

  describe '#call' do
    context 'with high failure notifications' do
      let!(:high_failure_notification) do
        create(:notification,
               state: 'programmed', failed_count: 5,
               appointment: create(:appointment, slot: create(:slot, date: next_valid_day(date: 1.day.from_now))))
      end
      let!(:low_failure_notification) do
        create(:notification,
               state: 'programmed', failed_count: 4,
               appointment: create(:appointment, slot: create(:slot, date: next_valid_day(date: 1.day.from_now))))
      end

      it 'includes notifications with failed_count >= 5' do
        expect(query.call).to include(high_failure_notification)
      end

      it 'excludes notifications with failed_count < 5' do
        expect(query.call).not_to include(low_failure_notification)
      end
    end

    context 'with stuck no_show notifications' do
      let!(:old_no_show_notification) { create(:notification, state: 'programmed', role: 'no_show') }
      let!(:recent_no_show_notification) { create(:notification, state: 'programmed', role: 'no_show') }

      before do
        travel_to 90.days.ago do
          old_no_show_notification.update!(
            appointment: create(:appointment, state: 'no_show',
                                              slot: create(:slot, date: next_valid_day(date: 30.days.from_now)))
          )
          recent_no_show_notification.update!(
            appointment: create(:appointment, state: 'no_show',
                                              slot: create(:slot, date: next_valid_day(date: 75.days.from_now)))
          )
        end
      end

      it 'includes no_show notifications more than 1 month old' do
        expect(query.call).to include(old_no_show_notification)
      end

      it 'excludes recent no_show notifications' do
        expect(query.call).not_to include(recent_no_show_notification)
      end
    end

    context 'with other stuck notifications' do
      let!(:past_reminder_notification) { create(:notification, state: 'programmed', role: 'reminder') }
      let!(:past_summon_notification) { create(:notification, state: 'programmed', role: 'summon') }
      let!(:future_reminder_notification) { create(:notification, state: 'programmed', role: 'reminder') }

      before do
        travel_to 90.days.ago do
          past_reminder_notification.update!(
            appointment: create(:appointment,
                                slot: create(:slot, date: next_valid_day(date: 85.days.from_now)))
          )
          past_summon_notification.update!(
            appointment: create(:appointment,
                                slot: create(:slot, date: next_valid_day(date: 84.days.from_now)))
          )
          future_reminder_notification.update!(
            appointment: create(:appointment,
                                slot: create(:slot, date: next_valid_day(date: 92.days.from_now)))
          )
        end
      end

      it 'includes past reminder notifications' do
        expect(query.call).to include(past_reminder_notification)
      end

      it 'includes past summon notifications' do
        expect(query.call).to include(past_summon_notification)
      end

      it 'excludes future notifications' do
        expect(query.call).not_to include(future_reminder_notification)
      end
    end

    context 'with notifications in different states' do
      let!(:programmed_notification) { create(:notification, state: 'programmed') }
      let!(:created_notification) { create(:notification, state: 'created') }
      let!(:sent_notification) { create(:notification, state: 'sent', external_id: '123') }

      before do
        travel_to 90.days.ago do
          programmed_notification.update!(
            appointment: create(:appointment, slot: create(:slot, date: next_valid_day(date: 85.days.from_now)))
          )
          created_notification.update!(
            appointment: create(:appointment, slot: create(:slot, date: next_valid_day(date: 85.days.from_now)))
          )
          sent_notification.update!(
            appointment: create(:appointment, slot: create(:slot, date: next_valid_day(date: 85.days.from_now)))
          )
        end
      end

      it 'includes only programmed notifications' do
        result = query.call
        expect(result).to include(programmed_notification)
        expect(result).not_to include(created_notification, sent_notification)
      end
    end

    context 'when there are no notifications to be marked as failed' do
      it 'returns an empty collection' do
        expect(query.call).to be_empty
      end
    end
  end
end
