require 'rails_helper'

RSpec.describe Appointment, type: :model do
  subject { build(:appointment) }

  it { should belong_to(:convict) }

  it {
    should define_enum_for(:origin_department).with_values(
      {
        bex: 0,
        gref_co: 1,
        pr: 2,
        greff_tpe: 3,
        greff_crpc: 4,
        greff_ca: 5
      }
    )
  }

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
      slot = create :slot, appointment_type: appointment_type
      appointment = create :appointment, :with_notifications, slot: slot
      appointment.book
      appointment.miss(send_notification: false)

      expect(appointment.state).to eq('no_show')
      expect(SmsDeliveryJob).not_to have_been_enqueued.with(appointment.no_show_notif)
    end

    it 'transitions from booked to missed and sending sms' do
      appointment_type = create :appointment_type
      slot = create :slot, appointment_type: appointment_type
      appointment = create :appointment, :with_notifications, slot: slot
      appointment.book
      appointment.miss(send_notification: true)

      expect(appointment.state).to eq('no_show')
      expect(SmsDeliveryJob).to have_been_enqueued.once.with(appointment.no_show_notif)
    end
  end

  describe '.in_organization' do
    it 'returns correct relation' do
      organization = create :organization
      place_in = create :place, organization: organization
      agenda_in = create :agenda, place: place_in
      slot_in = create :slot, agenda: agenda_in
      appointment_in = create :appointment, slot: slot_in
      create :appointment

      expect(Appointment.in_organization(organization)).to eq [appointment_in]
    end
  end

  describe '.for_a_place' do
    it 'returns correct relation' do
      place1 = create :place
      agenda1 = create :agenda, place: place1
      slot1 = create :slot, agenda: agenda1
      appointment1 = create :appointment, slot: slot1

      place2 = create :place
      agenda2 = create :agenda, place: place2
      slot2 = create :slot, agenda: agenda2
      appointment2 = create :appointment, slot: slot2

      expect(Appointment.for_a_place(place1)).to eq [appointment1]
      expect(Appointment.for_a_place(place2)).to eq [appointment2]
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

  describe 'future validation' do
    it 'validates that new appointment is in the future' do
      slot = build(:slot, date: Date.new(2018, 1, 1))
      appointment = build(:appointment, slot: slot)

      expect(appointment.valid?).to eq(false)
    end
  end
end
