require 'rails_helper'

RSpec.feature 'Convicts', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    before do
      create(:convict, first_name: 'michel', phone: '0607080910')
      create(:convict, first_name: 'Paul')

      visit convicts_path
    end

    it 'lists all convicts' do
      expect(page).to have_content('Michel')
      expect(page).to have_content('06 07 08 09 10')
      expect(page).to have_content('Paul')
    end

    it 'allows to delete convict' do
      within first('.convicts-item-container') do
        expect { click_link('Supprimer') }.to change { Convict.count }.by(-1)
      end
    end

    it 'filter convicts with search form' do
      expect(page).to have_content('Paul')

      fill_in 'search-field', with: 'Michel'
      click_button 'Recherche'

      expect(page).not_to have_content('Paul')
    end
  end

  describe 'creation' do
    it 'works' do
      visit new_convict_path

      select 'M.', from: 'Civilité'
      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'Enregistrer' }.to change { Convict.count }.by(1)
    end

    it 'creates a convict with his first appointment', js: true do
      allow_any_instance_of(Notification).to receive(:format_content)

      place = create(:place, name: 'McDo de Clichy')
      appointment_type = create(:appointment_type, name: 'Premier contact Spip')
      create(:slot, place: place, appointment_type: appointment_type, date: '10/10/2021', starting_time: '14h')
      create(:notification_type, appointment_type: appointment_type)

      visit new_convict_path

      select 'M.', from: 'Civilité'
      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'Prendre RDV' }.to change { Convict.count }.by(1)
      expect(page).to have_current_path(new_appointment_path(convict_id: Convict.last.id))

      select 'Premier contact Spip', from: 'Type de rendez-vous'
      select 'McDo de Clichy', from: 'Lieu'

      choose '10/10/2021 - 14:00'

      expect(page).to have_button('Enregistrer')
      expect { click_button 'Enregistrer' }.to change { Appointment.count }.by(1)
    end
  end

  describe 'update' do
    it 'works' do
      convict = create(:convict, last_name: 'Expresso')

      visit convicts_path

      within first('.convicts-item-container') { click_link 'Modifier' }

      fill_in 'Nom', with: 'Ristretto'
      click_button 'Enregistrer'

      convict.reload
      expect(convict.last_name).to eq('Ristretto')
    end
  end
end
