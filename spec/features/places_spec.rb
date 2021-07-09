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

      fill_in 'Nom', with: 'Spip du 58'
      click_button 'Enregistrer'

      place.reload

      expect(place.name).to eq('Spip du 58')
    end

    it 'allows to add agendas', js: true do
      place = create(:place, name: 'Spip du 93')

      visit edit_place_path(place)

      within first('.edit-place-agendas-container') do
        click_button 'Ajouter agenda'

        fill_in 'Nom', with: 'Agenda de Jean-Pierre'
      end

      expect { click_button('Enregistrer') }.to change { Agenda.count }.by(1)
    end
  end
end
