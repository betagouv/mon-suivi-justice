require 'rails_helper'

RSpec.describe 'UserAlerts', type: :feature do
  it 'allows an admin to create a UserAlert with target role and organization', logged_in_as: 'admin' do
    @organization = create(:organization, name: 'Test Organization')
    @user1 = create(:user, first_name: 'Michèle', last_name: 'John Doe', role: 'cpip', organization: @organization)
    create(:user, first_name: 'Bob', last_name: 'Dupneu', role: 'overseer', organization: @organization)

    visit admin_user_alerts_path
    expect(page).to have_content("Création d'alertes pour les utilisateurs")

    fill_in 'Contenu', with: 'Contenu de test'

    select @organization.name, from: 'Service'
    select 'cpip', from: 'Rôle'

    click_button 'Créer'

    expect(page).to have_content('Les alertes sont en cours de création')

    perform_enqueued_jobs

    expect(UserAlert.count).to eq(1)
    expect(UserAlert.last.params[:comment]).to eq('Contenu de test')
    expect(UserAlert.last.recipient).to eq(@user1)
  end

  it 'users can see the alerts and mark them as read', logged_in_as: 'cpip', js: true do
    alert = create(:user_alert, recipient: @user, read_at: nil, type: 'User', params: { comment: 'Contenu de test' })

    visit root_path

    expect(page).to have_content('Contenu de test')

    find("#mark_#{alert.id}_as_read").click

    expect(page).not_to have_content('Contenu de test')
  end
end
