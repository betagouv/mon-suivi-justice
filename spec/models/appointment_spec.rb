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

    it { is_expected.to have_states :created, :booked, :canceled, :fulfiled, :no_show }

    it { is_expected.to transition_from :created, to_state: :booked, on_event: :book }

    it { is_expected.to transition_from :booked, to_state: :fulfiled, on_event: :fulfil }

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
end
