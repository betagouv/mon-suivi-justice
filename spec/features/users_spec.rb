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
    it 'works' do
      visit new_user_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Email', with: 'robertdurand@justice.fr'
      fill_in 'Mot de passe', with: 'password'
      fill_in 'Confirmation du mot de passe', with: 'password'

      expect { click_button 'Enregistrer' }.to change { User.count }.by(1)
    end
  end

  describe 'roles' do
    it 'allows admin users to access everything' do
      visit convicts_path

      sidebar = find('section.sidebar')

      expect(sidebar).to have_link('PPSMJ')
      expect(sidebar).to have_link('Rendez-vous')
      expect(sidebar).to have_link('Lieux')
      expect(sidebar).to have_link('Créneaux')
      expect(sidebar).to have_link('Agents')
    end

    it 'forbid bex users to access some interfaces' do
      bex_user = create(:user, role: :bex)
      logout_current_user
      login_user(bex_user)

      visit convicts_path

      sidebar = find('section.sidebar')

      expect(sidebar).to have_link('PPSMJ')
      expect(sidebar).to have_link('Rendez-vous')
      expect(sidebar).not_to have_link('Lieux')
      expect(sidebar).not_to have_link('Créneaux')
      expect(sidebar).not_to have_link('Agents')
    end

    it 'allows cpip users to access appointment interface' do
      cpip_user = create(:user, role: :cpip)
      logout_current_user
      login_user(cpip_user)

      visit convicts_path

      sidebar = find('section.sidebar')

      expect(sidebar).to have_link('PPSMJ')
      expect(sidebar).to have_link('Rendez-vous')
      expect(sidebar).not_to have_link('Lieux')
      expect(sidebar).not_to have_link('Créneaux')
      expect(sidebar).not_to have_link('Agents')
    end
  end
end
