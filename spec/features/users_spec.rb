require 'rails_helper'

RSpec.feature 'Users', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    before do
      create(:user, first_name: 'Jeanne', last_name: 'Montirello')
      create(:user, first_name: 'Michèle')

      visit users_path
    end

    it 'lists all users' do
      expect(page).to have_content('MONTIRELLO Jeanne')
      expect(page).to have_content('Michèle')
    end

    it 'allows to delete user' do
      within first('.users-item-container') do
        expect { click_link('Supprimer') }.to change { User.count }.by(-1)
      end
    end
  end

  describe 'creation' do
    it 'sends invitation to new user' do
      create :organization
      visit new_user_invitation_path
      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Email', with: 'robertdurand@justice.fr'
      expect { click_button 'Envoyer invitation' }.to change { User.count }.by(1)
    end
  end

  describe 'show' do
    it 'displays user data' do
      user = create(:user, first_name: 'Jeanne',
                           last_name: 'Delajungle',
                           email: 'jeanne@delajungle.fr')

      visit user_path(user.id)

      expect(page).to have_content('Jeanne')
      expect(page).to have_content('DELAJUNGLE')
      expect(page).to have_content('jeanne@delajungle.fr')
    end
  end

  describe 'edition' do
    it 'works' do
      user = create(:user, first_name: 'Jeanne')

      visit edit_user_path(user.id)

      fill_in 'Prénom', with: 'Mireille'

      click_button 'Enregistrer'

      user.reload
      expect(user.first_name).to eq('Mireille')
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
      department = create :department, number: '01', name: 'Ain'

      organization = create :organization
      create :areas_organizations_mapping, organization: organization, area: department

      bex_user = create(:user, role: :bex, organization: organization)
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
