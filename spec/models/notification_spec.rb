require 'rails_helper'

RSpec.describe Notification, type: :model do
  subject { build(:notification) }

  it { should belong_to(:appointment) }
  it { should validate_presence_of(:template) }

  it { should define_enum_for(:role).with_values(%i[summon reminder cancelation]) }
  it { should define_enum_for(:reminder_period).with_values(%i[one_day two_days]) }

  describe 'send_now' do
    it 'calls Sendinblue adapter' do
      cached_sms_sender = ENV['SMS_SENDER']
      ENV['SMS_SENDER'] = 'MSJ'

      Sidekiq::Testing.inline! do
        api_mock = instance_double(SibApiV3Sdk::TransactionalSMSApi)
        allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(api_mock)

        expect(api_mock).to receive(:send_transac_sms)

        notif = create(:notification)
        notif.send_now
      end

      ENV['SMS_SENDER'] = cached_sms_sender
    end
  end

  describe 'program' do
    it 'sends at the proper delivery time' do
      slot = create(:slot, date: '04/08/2021', starting_time: new_time_for(17, 30))
      appointment_type = create(:appointment_type)
      create(:notification_type, appointment_type: appointment_type,
                                 role: :reminder,
                                 reminder_period: :two_days)

      appointment = create(:appointment, appointment_type: appointment_type, slot: slot)

      NotificationFactory.perform(appointment)

      notification = appointment.reminder_notif
      expected_time = DateTime.new(2021, 8, 2, 17, 30, 0).asctime.in_time_zone('Paris')

      expect(SmsDeliveryJob).to receive(:set).with(wait_until: expected_time) { double(perform_later: true) }

      notification.program
    end
  end

  describe 'state machine' do
    it { is_expected.to have_states :created, :programmed, :canceled, :sent }

    it { is_expected.to transition_from :created, to_state: :programmed, on_event: :program }
    it { is_expected.to transition_from :created, to_state: :sent, on_event: :send_now }

    it { is_expected.to transition_from :programmed, to_state: :sent, on_event: :send_then }
    it { is_expected.to transition_from :programmed, to_state: :canceled, on_event: :cancel }
  end
end
