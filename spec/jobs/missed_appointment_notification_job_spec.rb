require 'rails_helper'

RSpec.describe MissedAppointmentNotificationJob, type: :job do
  describe '#perform_later' do
    it 'queues the job' do
      MissedAppointmentNotificationJob.perform_later
      expect(MissedAppointmentNotificationJob).to have_been_enqueued.once
    end
  end

  describe '#perform' do
    before do
      @appointment_type1 = create :appointment_type
      @appointment_type2 = create :appointment_type
      @appointment_type3 = create :appointment_type
      slot = create :slot, appointment_type: @appointment_type1
      @appointment = create :appointment, appointment_type: @appointment_type1, slot: slot
      create :notification_type, appointment_type: @appointment_type3, role: :missed, template: 'whatever'
    end

    it 'creates 2 missed notification type' do
      expect { MissedAppointmentNotificationJob.new.perform }.to change(NotificationType, :count).from(1).to(3)
    end
    it 'creates 1 missed notification' do
      expect { MissedAppointmentNotificationJob.new.perform }.to change(Notification, :count).from(0).to(1)
    end
    it 'creates notification type for first appointment type' do
      MissedAppointmentNotificationJob.new.perform
      expect(
        NotificationType.find_by(
          appointment_type: @appointment_type1, role: :missed,
          template: 'Vous avez manqué votre "RDV suivi", veuillez contacter votre SPIP dans les meilleurs délais.'
        )
      ).not_to be nil
    end
    it 'creates notification type for first appointment type' do
      MissedAppointmentNotificationJob.new.perform
      expect(
        NotificationType.find_by(
          appointment_type: @appointment_type2, role: :missed,
          template: 'Vous avez manqué votre "RDV suivi", veuillez contacter votre SPIP dans les meilleurs délais.'
        )
      ).not_to be nil
    end
    it 'creates notification for the appointment' do
      MissedAppointmentNotificationJob.new.perform
      expect(
        Notification.find_by(
          appointment: @appointment, role: :missed,
          template: 'Vous avez manqué votre "RDV suivi", veuillez contacter votre SPIP dans les meilleurs délais.'
        )
      ).not_to be nil
    end
  end
end
