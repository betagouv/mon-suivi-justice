require 'rails_helper'

RSpec.feature 'Places', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    before do
      create(:place, name: 'Spip 78')
      create(:place, name: 'Spip 83')

      visit places_path
    end

    it 'lists all places' do
      expect(page).to have_content('Spip 78')
      expect(page).to have_content('Spip 83')
    end

    it 'allows to delete convict' do
      within first('.places-item-container') do
        expect { click_link('Supprimer') }.to change { Place.count }.by(-1)
      end
    end
  end

  describe 'creation' do
    it 'works' do
      visit new_place_path

      fill_in 'Nom', with: 'Spip 72'
      fill_in 'Adresse', with: '93 rue des charmes 72200 La Flèche'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'Enregistrer' }.to change { Place.count }.by(1)
    end
  end

  describe 'update' do
    it 'works' do
      place = create(:place, name: 'Spip du 78')
      visit places_path
      within first('.places-item-container') { click_link 'Modifier' }
      fill_in :place_name, with: 'Spip du 58'
      within("#edit_place_#{place.id}") { click_button 'Enregistrer' }
      expect(place.reload.name).to eq('Spip du 58')
    end

    it 'creates agenda' do
      place = create(:place, name: 'Spip du 93')
      visit edit_place_path(place)
      within '#new_agenda' do
        fill_in :agenda_name, with: 'Agenda de Jean-Pierre'
        expect { click_button('Ajouter agenda') }.to change { Agenda.count }.by(1)
      end
    end

    it 'updates agenda' do
      place = create :place, name: 'Spip du 93'
      agenda = create :agenda, name: 'test_agenda', place: place
      visit edit_place_path place
      within "#edit_agenda_#{agenda.id}" do
        fill_in :agenda_name, with: 'updated_name'
        click_button 'Enregistrer'
      end
      expect(agenda.reload.name).to eq 'updated_name'
    end

    it 'deeted agenda' do
      place = create :place, name: 'Spip du 93'
      agenda = create :agenda, name: 'test_agenda', place: place
      visit edit_place_path place
      expect { click_link('Supprimer') }.to change(place.agendas, :count).from(1).to(0)
    end

    it 'allows to select appointment_types' do
      place = create(:place, name: 'Spip du 91')
      apt_type = create(:appointment_type, name: 'Premier contact Spip')

      expect(place.appointment_types).to be_empty

      visit edit_place_path(place)

      within first('.edit-place-appointment-types-container') do
        check 'Premier contact Spip'
      end

      click_button('Enregistrer')

      place.reload

      expect(place.appointment_types.first).to eq(apt_type)
    end
  end
end
