require 'rails_helper'

RSpec.feature 'Convicts', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    before do
      create(:convict, first_name: 'Michel')
      create(:convict, first_name: 'Paul')

      visit convicts_path
    end

    it 'lists all convicts' do
      expect(page).to have_content('Michel')
      expect(page).to have_content('Paul')
    end

    it 'allows to delete convict' do
      within first('.convicts-item-container') do
        expect { click_link('Supprimer') }.to change { Convict.count }.by(-1)
      end
    end
  end

  describe 'creation' do
    it 'creates a convict with his first appointment' do
      place = create(:place, name: 'McDo de Clichy')
      create(:slot, place: place, date: '10/10/2021', starting_time: '14h')

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      select 'McDo de Clichy', from: 'Lieu du premier rendez-vous'

      expect { click_button 'Choisir créneau' }.to change { Convict.count }.by(1)
      expect(page).to have_current_path(new_first_appointment_path(Convict.last.id, place.id))

      choose '10/10/2021 - 14:00'

      expect { click_button 'Créer rendez-vous' }.to change { Appointment.count }.by(1)
    end
  end
end
