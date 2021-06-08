require 'rails_helper'

RSpec.feature 'Users', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    before do
      create(:user, first_name: 'Jeanne')
      create(:user, first_name: 'Michèle')

      visit users_path
    end

    it 'lists all users' do
      expect(page).to have_content('Jeanne')
      expect(page).to have_content('Michèle')
    end

    it 'allows to delete convict' do
      within first('.users-item-container') do
        expect { click_link('Supprimer') }.to change { User.count }.by(-1)
      end
    end
  end

  describe 'creation' do
    it "works" do
      visit new_user_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Email', with: 'robertdurand@justice.fr'
      fill_in 'Mot de passe', with: 'password'
      fill_in 'Confirmation du mot de passe', with: 'password'

      expect { click_button 'Créer Agent' }.to change { User.count }.by(1)
    end
  end
end
