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

    it 'allows to filter convicts' do
      expect(page).to have_content('Paul')

      fill_in 'search-field', with: 'Michel'
      click_button 'Filtrer'

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

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)
    end

    it 'creates a convict with his first appointment', js: true do
      place = create(:place, name: 'McDo de Clichy')
      agenda = create(:agenda, place: place, name: 'Agenda de Jean-Louis')
      create(:agenda, place: place, name: 'Agenda de Michel')

      appointment_type = create(:appointment_type, :with_notification_types, name: 'Premier contact Spip')
      create(:slot, agenda: agenda, appointment_type: appointment_type, date: '10/10/2021', starting_time: '14h')
      create(:notification_type, appointment_type: appointment_type)

      visit new_convict_path

      select 'M.', from: 'Civilité'
      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'submit-with-appointment' }.to change { Convict.count }.by(1)
      expect(page).to have_current_path(new_appointment_path(convict_id: Convict.last.id))

      select 'Premier contact Spip', from: 'Type de rendez-vous'
      select 'McDo de Clichy', from: 'Lieu'
      select 'Agenda de Jean-Louis', from: 'Agenda'

      choose '14:00'

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

  describe 'show' do
    it 'displays infos on convict' do
      convict = create(:convict, last_name: 'Noisette',
                                 first_name: 'Café',
                                 phone: '0607060706')

      place = create(:place, name: 'SPIP du 93')
      agenda = create(:agenda, place: place)

      slot1 = create(:slot, agenda: agenda,
                            date: '06/10/2021',
                            starting_time: new_time_for(13, 0))

      slot2 = create(:slot, agenda: agenda,
                            date: '08/12/2021',
                            starting_time: new_time_for(15, 30))

      create(:appointment, slot: slot1, convict: convict)
      create(:appointment, slot: slot2, convict: convict)

      visit convict_path(convict)

      expect(page).to have_content('Café')
      expect(page).to have_content('NOISETTE')
      expect(page).to have_content('06 07 06 07 06')

      expect(page).to have_content('A été convoqué au SPIP du 93 le 06/10/2021 à 13:00')
      expect(page).to have_content('A été convoqué au SPIP du 93 le 08/12/2021 à 15:30')
    end
  end
end
