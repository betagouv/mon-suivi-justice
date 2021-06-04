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
      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      within ('.convict-first-appointment-container') do
        fill_in 'Date', with: '22/08/21'
        # fill_in 'Créneau', with: '2'
      end

      expect { click_button 'Créer PPSMJ' }.to change { Convict.count }.by(1)
                                           .and change { Appointment.count }.by(1)
    end
  end

  # describe 'can be updated' do
  # end
end
