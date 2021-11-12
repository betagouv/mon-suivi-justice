require 'rails_helper'

RSpec.describe Appointment, type: :model do
  subject { build(:appointment) }

  it { should belong_to(:convict) }
  it { should belong_to(:slot) }
  it { should belong_to(:appointment_type) }

  it { should define_enum_for(:origin_department).with_values(%i[bex gref_co pr]) }

  describe 'state machine' do
    before do
      allow(subject).to receive(:summon_notif)
                    .and_return(create(:notification))
      allow(subject).to receive(:reminder_notif)
                    .and_return(create(:notification))
      allow(subject).to receive(:cancelation_notif)
                    .and_return(create(:notification))
    end

    it { is_expected.to have_states :created, :booked, :canceled, :fulfiled, :no_show, :excused }

    it { is_expected.to transition_from :created, to_state: :booked, on_event: :book }

    it { is_expected.to transition_from :booked, to_state: :fulfiled, on_event: :fulfil }
    it { is_expected.to transition_from :booked, to_state: :excused, on_event: :excuse }

    it do
      allow(subject).to receive(:reminder_notif).and_return(create(:notification, state: 'programmed'))
      is_expected.to transition_from :booked, to_state: :canceled, on_event: :cancel
    end

    it 'transitions from booked to missed without sending sms' do
      appointment_type = create :appointment_type
      appointment = create :appointment, :with_notifications, appointment_type: appointment_type
      appointment.book
      appointment.miss(send_notification: false)

      expect(appointment.state).to eq('no_show')
      expect(SmsDeliveryJob).not_to have_been_enqueued.with(appointment.no_show_notif)
    end

    it 'transitions from booked to missed and sending sms' do
      appointment_type = create :appointment_type
      appointment = create :appointment, :with_notifications, appointment_type: appointment_type
      appointment.book
      appointment.miss(send_notification: true)

      expect(appointment.state).to eq('no_show')
      expect(SmsDeliveryJob).to have_been_enqueued.once.with(appointment.no_show_notif)
    end
  end

  describe '.in_organization' do
    before do
      @organization = create :organization
      place_in = create :place, organization: @organization
      agenda_in = create :agenda, place: place_in
      slot_in = create :slot, agenda: agenda_in
      @appointment_in = create :appointment, slot: slot_in
      create :appointment
    end

    it 'returns correct relation' do
      expect(Appointment.in_organization(@organization)).to eq [@appointment_in]
    end
  end

  describe '.in_the_past?' do
    let(:frozen_date) { Date.new 2020, 1, 1 }
    before { allow(Date).to receive(:today).and_return frozen_date }

    it 'returns true if appointment is in the past' do
      slot = Slot.new(date: Date.new(2018, 1, 1))
      appointment = Appointment.new(slot: slot)

      expect(appointment.in_the_past?).to eq(true)
    end

    it 'returns false if appointment is not in the past' do
      slot = Slot.new(date: Date.new(2021, 1, 1))
      appointment = Appointment.new(slot: slot)

      expect(appointment.in_the_past?).to eq(false)
    end
  end
end
