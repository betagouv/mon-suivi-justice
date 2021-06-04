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

      expect { click_button 'Créer Lieu' }.to change { Place.count }.by(1)
    end
  end
end
