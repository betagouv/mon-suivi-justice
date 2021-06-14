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
    it 'works' do
      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'Enregistrer' }.to change { Convict.count }.by(1)
    end

    it 'creates a convict with his first appointment', js: true do
      place = create(:place, name: 'McDo de Clichy')
      slot = create(:slot, place: place, date: '10/10/2021', starting_time: '14h')
      create(:appointment_type, name: 'Premier contact Spip')

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'Prendre RDV' }.to change { Convict.count }.by(1)
      expect(page).to have_current_path(new_appointment_path(convict_id: Convict.last.id))

      select 'McDo de Clichy', from: 'Lieu'
      select 'Premier contact Spip', from: 'Type de rendez-vous'

      click_link 'Charger créneaux'

      choose '10/10/2021 - 14:00'

      expect(page).to have_button('Enregistrer')
      expect { click_button 'Enregistrer' }.to change { Appointment.count }.by(1)

      slot.reload
      expect(slot.available).to eq(false)
    end
  end
end
