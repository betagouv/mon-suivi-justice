require 'rails_helper'

RSpec.feature 'Appointments', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    before do
      slot1 = create(:slot, date: '06/06/2021', starting_time: new_time_for(13, 0))
      slot2 = create(:slot, date: '08/08/2021', starting_time: new_time_for(15, 30))

      create(:appointment, slot: slot1)
      create(:appointment, slot: slot2)

      visit appointments_path
    end

    it 'lists all appointments' do
      expect(page).to have_content('06/06/2021')
      expect(page).to have_content('13:00')
      expect(page).to have_content('08/08/2021')
      expect(page).to have_content('15:30')
    end

    it 'filter appointments with search form' do
      expect(page).to have_content('06/06/2021')

      fill_in 'search-field', with: '08/08/2021'
      click_button 'Recherche'

      expect(page).not_to have_content('06/06/2021')
    end
  end

  describe 'creation', js: true do
    it 'works' do
      create(:convict, first_name: 'JP', last_name: 'Cherty')
      place = create(:place, name: 'KFC de Chatelet')
      create(:slot, place: place, date: '10/10/2021', starting_time: '16h')
      appointment_type = create(:appointment_type, name: 'Premier contact Spip')
      create(:notification_type, appointment_type: appointment_type)

      visit new_appointment_path

      select 'CHERTY Jp', from: 'PPSMJ'
      select 'KFC de Chatelet', from: 'Lieu'
      select 'Premier contact Spip', from: 'Type de rendez-vous'

      click_link 'Afficher les créneaux'

      choose '10/10/2021 - 16:00'

      expect(page).to have_button('Enregistrer')
      expect { click_button 'Enregistrer' }.to change { Appointment.count }.by(1)
                                           .and change { Notification.count }.by(1)
    end
  end
end
