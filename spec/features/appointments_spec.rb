require 'rails_helper'

RSpec.feature 'Appointments', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    it 'lists all appointments' do
      slot1 = create(:slot, date: '06/06/2021', starting_time: Time.new(2021, 6, 21, 13, 0, 0, '+00:00'))
      slot2 = create(:slot, date: '08/08/2021', starting_time: Time.new(2021, 6, 21, 15, 30, 0, '+00:00'))

      create(:appointment, slot: slot1)
      create(:appointment, slot: slot2)

      visit appointments_path

      expect(page).to have_content('06/06/2021')
      expect(page).to have_content('13:00')
      expect(page).to have_content('08/08/2021')
      expect(page).to have_content('15:30')
    end
  end

  describe 'creation', js: true do
    it 'works' do
      create(:convict, first_name: 'JP', last_name: 'Cherty')
      place = create(:place, name: 'KFC de Chatelet')
      slot = create(:slot, place: place, date: '10/10/2021', starting_time: '16h')
      create(:appointment_type, name: 'Premier contact Spip')

      visit new_appointment_path

      select 'JP Cherty', from: 'PPSMJ'
      select 'KFC de Chatelet', from: 'Lieu'
      select 'Premier contact Spip', from: 'Type de rendez-vous'

      click_link 'Charger créneaux'

      choose '10/10/2021 - 16:00'

      expect(page).to have_button('Enregistrer')
      expect { click_button 'Enregistrer' }.to change { Appointment.count }.by(1)

      slot.reload
      expect(slot.available).to eq(false)
    end
  end
end
