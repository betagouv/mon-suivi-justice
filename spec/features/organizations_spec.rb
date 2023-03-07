require 'rails_helper'

RSpec.feature 'Organizations', type: :feature do
  before do
    create_admin_user_and_login
  end

  scenario 'An admin consults organization index' do
    create :organization, name: 'SPIP 92'
    create :organization, name: 'SPIP 93'
    visit organizations_path
    expect(page).to have_content('SPIP 92')
    expect(page).to have_content('SPIP 93')
  end

  scenario 'An admin creates a new organization' do
    create :appointment_type
    create_default_notification_types
    visit organizations_path

    click_button 'Nouveau service'
    fill_in :organization_name, with: 'SPIP 75'
    expect { click_button 'Enregistrer' }.to change(Organization, :count).from(1).to(2)
                                         .and change { NotificationType.count }.by(5)
    expect(page).to have_content('SPIP 75')
  end

  scenario 'An admin updates an organization' do
    create :organization, name: 'SPIP 92'
    visit organizations_path
    within first('.organizations-item-container') do
      click_link 'Modifier'
    end
    fill_in :organization_name, with: 'SPIP 75'
    click_button 'Enregistrer'
    expect(page).to have_content('SPIP 75')
  end

  describe 'update' do
    it 'allows to select a timezone' do
      orga = create :organization

      visit edit_organization_path(orga)

      select 'UTC + 04:00 - La Réunion', from: 'Fuseau horaire'

      click_button 'Enregistrer'

      orga.reload
      expect(orga.time_zone).to eq('Europe/Samara')
    end
  end
end
