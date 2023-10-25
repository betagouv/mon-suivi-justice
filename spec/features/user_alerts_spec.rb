require 'rails_helper'

RSpec.describe 'UserAlerts', type: :feature, js: true do
  it 'allows an admin to create a UserAlert with target role and organization', logged_in_as: 'admin' do
    @organization = create(:organization, name: 'Test Organization')
    @user1 = create(:user, first_name: 'Michèle', last_name: 'John Doe', role: 'cpip', organization: @organization)
    create(:user, first_name: 'Bob', last_name: 'Dupneu', role: 'overseer', organization: @organization)

    visit new_admin_user_alert_path
    expect(page).to have_content('Création Alertes Utilisateurs')

    find('.trix-content').set('Contenu de test')

    select @organization.name, from: 'service'
    select 'cpip', from: 'rôle'

    click_button 'Créer un(e) Alerte utilisateur'

    expect(page).to have_content('Les alertes sont en cours de création')

    perform_enqueued_jobs

    expect(UserAlert.count).to eq(1)
    expect(UserAlert.last.content.to_plain_text).to eq("\n  Contenu de test")
    expect(UserUserAlert.last.user).to eq(@user1)
  end

  it 'users can see the alerts and mark them as read', logged_in_as: 'cpip', js: true do
    create(:user_alert, users: [@user], alert_type: 'error',
                        content: 'Contenu de test')

    visit root_path

    expect(page).to have_content('Contenu de test')
    page.find("#user_user_alert_#{UserUserAlert.last.id}").has_css?('fr-alert fr-alert--error')
    find("#mark_#{UserUserAlert.last.id}_as_read").click
    expect(page).not_to have_content('Contenu de test')
  end

  it 'users cannot see alerts targeted at another role', logged_in_as: 'cpip', js: true do
    bex_user = create(:user, first_name: 'Bob', last_name: 'Dupneu', role: 'overseer', organization: @user.organization)

    create(:user_alert, users: [bex_user], alert_type: 'error',
                        content: 'Contenu de test', roles: 'bex')

    visit root_path

    expect(page).not_to have_content('Contenu de test')
  end

  it 'users cannot see alerts targeted at another service', logged_in_as: 'cpip', js: true do
    create(:user_alert, alert_type: 'error',
                        content: 'Contenu de test', services: create(:organization, name: 'Other org').name)

    visit root_path

    expect(page).not_to have_content('Contenu de test')
  end
end
