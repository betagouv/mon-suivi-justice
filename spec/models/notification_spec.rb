require 'rails_helper'

RSpec.describe Notification, type: :model do
  subject { build(:notification) }

  it { should belong_to(:appointment) }
  it { should validate_presence_of(:content) }

  it { should define_enum_for(:role).with_values(%i[summon reminder cancelation no_show reschedule]) }
  it { should define_enum_for(:reminder_period).with_values(%i[one_day two_days]) }

  describe 'send_now' do
    it 'trigger sms delivery job' do
      notif = create(:notification)
      notif.send_now
      expect(SmsDeliveryJob).to have_been_enqueued.once.with(notif)
    end
  end

  describe 'program' do
    it 'sends at the proper delivery time' do
      appointment_type = create(:appointment_type)

      slot_date = DateTime.current.next_occurring(:monday)
      slot_starting_time = Time.new(2021, 6, 21, slot_date.hour, slot_date.min, slot_date.sec)

      slot = create(:slot, date: slot_date, appointment_type: appointment_type, starting_time: slot_starting_time)
      create(:notification_type, appointment_type: appointment_type,
                                 role: :reminder,
                                 reminder_period: :two_days)

      appointment = create(:appointment, slot: slot)

      NotificationFactory.perform(appointment)

      notification = appointment.reminder_notif
      expected_time = (slot_date - 2).asctime.in_time_zone('Paris')

      expect(SmsDeliveryJob).to receive(:set).with(wait_until: expected_time) { double(perform_later: true) }

      notification.program
    end
  end

  describe '.in_organization' do
    it 'returns correct relation' do
      organization = create :organization
      place_in = create :place, organization: organization
      agenda_in = create :agenda, place: place_in
      slot_in = create :slot, agenda: agenda_in
      appointment_in = create :appointment, slot: slot_in
      notification_in = create :notification, appointment: appointment_in

      appointment_out = create :appointment
      create :notification, appointment: appointment_out

      expect(Notification.in_organization(organization)).to eq [notification_in]
    end
  end

  describe 'state machine' do
    it { is_expected.to have_states :created, :programmed, :canceled, :sent, :received, :failed }

    it { is_expected.to transition_from :created, to_state: :programmed, on_event: :program }
    it { is_expected.to transition_from :created, to_state: :sent, on_event: :send_now }

    it { is_expected.to transition_from :programmed, to_state: :sent, on_event: :send_then }
    it { is_expected.to transition_from :programmed, to_state: :canceled, on_event: :cancel }

    it { is_expected.to transition_from :sent, to_state: :received, on_event: :receive }
    it { is_expected.to transition_from :sent, to_state: :failed, on_event: :failed_send }
  end
end
