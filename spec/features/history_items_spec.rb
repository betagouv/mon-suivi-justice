require 'rails_helper'

RSpec.feature 'HistoryItems', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'for a Convict' do
    before do
      @convict = create(:convict, phone: nil, refused_phone: true)
      @appointment = create(:appointment, :with_notifications, convict: @convict)
    end

    it 'displays new appointments' do
      expect { @appointment.book }.to change { HistoryItem.count }.by(1)

      visit convict_path(@convict)

      expect(page).to have_content('Nouveau RDV')
    end

    it 'displays when appointments are fulfiled' do
      @appointment.book
      expect { @appointment.fulfil }.to change { HistoryItem.count }.by(1)

      visit convict_path(@convict)

      expect(page).to have_content("s'est bien présenté(e) à son rendez-vous")
    end

    it 'displays when appointments are missed' do
      @appointment.book
      expect { @appointment.miss }.to change { HistoryItem.count }.by(1)

      visit convict_path(@convict)

      expect(page).to have_content("ne s'est pas présenté(e) à son rendez-vous")
    end
  end

  describe 'for an appointment' do
    before do
      @appointment = create(:appointment)
      @summon_notif = create(:notification, appointment: @appointment,
                                            role: 'summon',
                                            content: 'Vous êtes encore convoqué...')

      @reminder_notif = create(:notification, appointment: @appointment,
                                              role: 'reminder',
                                              state: 'programmed',
                                              content: 'RAPPEL Vous êtes encore convoqué...')

      @cancelation_notif = create(:notification, appointment: @appointment,
                                                 role: 'cancelation',
                                                 content: 'Finalement non :/')
    end

    it 'displays summon notification content' do
      expect { @summon_notif.send_now }.to change { HistoryItem.count }.by(1)

      visit appointment_path(@appointment)

      expect(page).to have_content('Vous êtes encore convoqué...')
    end

    it 'displays reminder notification content' do
      expect { @reminder_notif.send_then }.to change { HistoryItem.count }.by(1)

      visit appointment_path(@appointment)

      expect(page).to have_content('RAPPEL Vous êtes encore convoqué...')
    end

    it 'displays cancelation notification content' do
      expect { @cancelation_notif.send_now }.to change { HistoryItem.count }.by(1)

      visit appointment_path(@appointment)

      expect(page).to have_content('Finalement non :/')
    end
  end
end
