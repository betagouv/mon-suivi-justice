require 'rails_helper'

RSpec.feature 'Users', type: :feature do
  describe 'index', logged_in_as: 'admin' do
    before do
      organization = create(:organization)
      create(:user, first_name: 'Jeanne', last_name: 'Montirello', organization:)
      create(:user, first_name: 'Michèle', organization:)

      visit users_path
    end

    it 'lists all users' do
      expect(page).to have_content('MONTIRELLO Jeanne')
      expect(page).to have_content('Michèle')
    end

    it 'allows to delete user' do
      user_row = find('tbody > tr', text: 'MONTIRELLO')

      within user_row do
        expect { click_link('Supprimer') }.to change { User.count }.by(-1)
      end
    end
  end

  describe 'creation', logged_in_as: 'admin' do
    it 'sends invitation to new user', js: true do
      create :organization
      visit new_user_invitation_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Email', with: 'robertdurand@justice.fr'
      fill_in 'Numéro de téléphone', with: '0644444444'

      expect { click_button 'Envoyer invitation' }.to change { User.count }.by(1)
      expect(User.last.phone).to eq('+33644444444')
    end
  end

  describe 'show', logged_in_as: 'admin' do
    it 'displays user data' do
      user = create(:user, first_name: 'Jeanne',
                           last_name: 'Delajungle',
                           email: 'jeanne@delajungle.fr',
                           phone: '+33644444444',
                           organization: @user.organization)

      visit user_path(user.id)

      expect(page).to have_content('Jeanne')
      expect(page).to have_content('DELAJUNGLE')
      expect(page).to have_content('jeanne@delajungle.fr')
      expect(page).to have_content('06 44 44 44 44')
    end
  end

  describe 'edition', logged_in_as: 'cpip' do
    it 'works' do
      logout(scope: :user)
      login_as(@user, scope: :user)

      visit edit_user_path(@user.id)

      fill_in 'Prénom', with: 'Mireille'
      fill_in 'Numéro de téléphone', with: '0644444444'
      uncheck "Partage de l'email aux probationnaires suivis"

      click_button 'Enregistrer'

      @user.reload
      expect(@user.first_name).to eq('Mireille')
      expect(@user.phone).to eq('+33644444444')
      expect(@user.share_email_to_convict).to eq(false)
    end

    it 'remove linked convict if role is changed', logged_in_as: 'local_admin_spip' do
      cpip = create(:user, first_name: 'Bob', last_name: 'Dupneu', role: 'cpip', organization: @user.organization)
      create(:convict, user: cpip, organizations: [cpip.organization])

      expect(cpip.convicts.count).to eq(1)

      visit edit_user_path(cpip.id)

      select 'Secrétariat SPIP', from: :user_role

      click_button 'Enregistrer'

      expect(cpip.convicts.count).to eq(0)
    end
  end

  describe 'roles', logged_in_as: 'admin' do
    it 'allows admin users to access everything' do
      visit convicts_path

      main_nav = find('nav')

      expect(main_nav).to have_link('Probationnaires')
      expect(main_nav).to have_link('Convocations')
      expect(main_nav).to have_link('Lieux')
      expect(main_nav).to have_link('Créneaux')
      expect(main_nav).to have_link('Agents')
    end

    it 'forbid bex users to access some interfaces' do
      organization = create :organization, organization_type: 'tj'

      bex_user = create(:user, role: :bex, organization:)
      logout_current_user
      login_user(bex_user)

      visit convicts_path

      main_nav = find('nav')

      expect(main_nav).to have_link('Probationnaires')
      expect(main_nav).not_to have_link('Administration')
    end

    it 'allows cpip users to access appointment interface', logged_in_as: 'cpip' do
      visit convicts_path

      main_nav = find('nav')

      expect(main_nav).to have_link('Probationnaires')
      expect(main_nav).to have_link('Convocations')
      expect(main_nav).not_to have_link('Administration')
    end
  end
end
