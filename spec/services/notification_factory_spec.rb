require 'rails_helper'

RSpec.describe NotificationFactory do
  describe 'perform' do
    it 'creates notifications for an appointment' do
      appointment_type = create(:appointment_type)

      create(:notification_type, appointment_type: appointment_type,
                                 role: :summon,
                                 template: 'RDV pris le {rdv.date} à {rdv.heure}')

      create(:notification_type, appointment_type: appointment_type,
                                 role: :reminder,
                                 template: 'Rappel: rdv le {rdv.date} à {rdv.heure}')

      slot = create(:slot, date: '08/08/2021', starting_time: new_time_for(15, 30))

      appointment = create(:appointment, appointment_type: appointment_type,
                                         slot: slot)

      expect { NotificationFactory.perform(appointment) }.to change { Notification.count }.by(2)

      appointment.reload
      expect(appointment.notifications.count).to eq(2)

      summon_notif = appointment.notifications.where(role: :summon).first
      reminder_notif = appointment.notifications.where(role: :reminder).first

      expect(summon_notif.content).to eq('RDV pris le 08/08/2021 à 15h30')
      expect(reminder_notif.content).to eq('Rappel: rdv le 08/08/2021 à 15h30')
    end
  end

  describe 'setup_template' do
    it 'translates human readable template into a ruby usable one' do
      human_template = 'RDV pris le {rdv.date} à {rdv.heure}'
      expected = 'RDV pris le %{appointment_date} à %{appointment_hour}'

      result = NotificationFactory.setup_template(human_template)

      expect(result).to eq(expected)
    end
  end
end
