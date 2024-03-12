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

  it 'should free the slot when appointment is destroyed' do
    orga = create(:organization)
    slot = create(:slot, capacity: 1)
    convict = create(:convict, organizations: [orga])
    appointment = create(:appointment, convict:, slot:)
    appointment.book(send_notification: false)
    slot.reload

    expect(slot.full?).to eq(true)
    expect(slot.used_capacity).to eq(1)

    convict.destroy!

    slot.reload
    expect(slot.full?).to eq(false)
    expect(slot.used_capacity).to eq(0)
  end

  it 'should free the slot when appointment canceled and destroyed' do
    orga = create(:organization)
    slot = create(:slot, capacity: 1)
    convict = create(:convict, organizations: [orga])
    appointment = create(:appointment, convict:, slot:)
    appointment.book(send_notification: false)
    slot.reload

    expect(slot.full?).to eq(true)
    expect(slot.used_capacity).to eq(1)
    appointment.cancel(send_notification: false)

    slot.reload
    expect(slot.used_capacity).to eq(0)

    convict.destroy!
    slot.reload
    expect(slot.full?).to eq(false)
    expect(slot.used_capacity).to eq(0)
  end

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
    it { is_expected.to transition_from :excused, :fulfiled, :no_show, to_state: :booked, on_event: :rebook }

    it do
      allow(subject).to receive(:reminder_notif).and_return(create(:notification, state: 'programmed'))
      is_expected.to transition_from :booked, to_state: :canceled, on_event: :cancel
    end

    it 'transitions from booked to missed without sending sms' do
      appointment_type = create :appointment_type
      slot = create(:slot, appointment_type:)
      appointment = create(:appointment, :with_notifications, slot:)
      appointment.book
      appointment.miss(send_notification: false)

      expect(appointment.state).to eq('no_show')
      expect(SmsDeliveryJob).not_to have_been_enqueued.with(appointment.no_show_notif.id)
    end

    it 'transitions from booked to missed and sending sms' do
      appointment_type = create :appointment_type
      slot = create(:slot, appointment_type:)
      appointment = create(:appointment, :with_notifications, slot:)
      appointment.book
      appointment.miss(send_notification: true)

      expect(appointment.state).to eq('no_show')
      expect(SmsDeliveryJob).to have_been_enqueued.once.with(appointment.no_show_notif.id)
    end
  end

  describe '.in_organization' do
    it 'returns correct relation' do
      organization = create :organization
      place_in = create(:place, organization:)
      agenda_in = create :agenda, place: place_in
      slot_in = create :slot, agenda: agenda_in
      appointment_in = create :appointment, slot: slot_in
      create :appointment

      expect(Appointment.in_organization(organization)).to eq [appointment_in]
    end
  end

  describe '.in_the_past?' do
    let(:agenda) { build(:agenda) }
    it 'returns true if appointment is in the past' do
      slot = build(:slot, date: Date.today - 1.days, agenda:)
      appointment = Appointment.new(slot:)

      expect(appointment.in_the_past?).to eq(true)
    end

    it 'returns false if appointment is not in the past' do
      slot = build(:slot, date: Date.today + 1.days, agenda:)
      appointment = Appointment.new(slot:)

      appointment.save

      expect(appointment.in_the_past?).to eq(false)
    end
  end

  describe 'validations' do
    it 'validates that new appointment is in the future' do
      slot = build(:slot, date: Date.new(2018, 1, 1))
      appointment = build(:appointment, slot:)

      expect(appointment.valid?).to eq(false)
    end

    it 'validates that new appointment is not for discarded convict' do
      convict = create(:convict, discarded_at: Time.current)
      appointment = build(:appointment, convict:)

      expect(appointment.valid?).to eq(false)
      expect(appointment.errors[:convict])
                        .to include(I18n.t('activerecord.errors.models.appointment.attributes.convict.discarded'))
    end

    it 'validates new appointment for a convict with a phone but dont want to receive sms' do
      convict = create(:convict, phone: '+33612345678', refused_phone: true)
      appointment = create(:appointment, convict:)
      expect(appointment.valid?).to eq(true)
    end

    it 'validates that new appointment is not for convict without DoB' do
      convict = build(:convict, date_of_birth: nil)
      appointment = build(:appointment, convict:)

      expect(appointment.valid?).to eq(false)
      expect(appointment.errors[:convict])
                        .to include(I18n.t('activerecord.errors.models.appointment.attributes.convict.DoB'))
    end
    context 'when convict does not have DoB' do
      it 'validates that new appointment is not valid' do
        convict = build(:convict, date_of_birth: nil)
        appointment = build(:appointment, convict:)

        expect(appointment.valid?).to eq(false)
        expect(appointment.errors[:convict])
                          .to include(I18n.t('activerecord.errors.models.appointment.attributes.convict.DoB'))
      end
      context 'when user is admin' do
        it 'skip validates' do
          user = create(:user, :in_organization, role: :admin)
          convict = build(:convict, date_of_birth: nil)
          appointment = build(:appointment, convict:, inviter_user: user)

          expect(appointment.valid?).to eq(true)
        end
      end
      context 'when user is not admin' do
        it 'validates that new appointment is not valid for convict without DoB if non admin user' do
          user = create(:user, :in_organization, role: :cpip)
          convict = build(:convict, date_of_birth: nil)
          appointment = build(:appointment, convict:, inviter_user: user)

          expect(appointment.valid?).to eq(false)
          expect(appointment.errors[:convict])
                            .to include(I18n.t('activerecord.errors.models.appointment.attributes.convict.DoB'))
        end
      end
    end
  end
end
