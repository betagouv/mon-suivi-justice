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

  scenario 'An admin attaches departments to an organization' do
    create :department, number: '09', name: 'Ariège'
    create :organization, name: 'SPIP 92'
    visit organizations_path
    within first('.organizations-item-container') do
      click_link 'Modifier'
    end
    within '#department-form' do
      select 'Ariège', from: :areas_organizations_mapping_area_id
      expect { click_button 'Ajouter' }.to change(AreasOrganizationsMapping, :count).from(1).to(2)
    end
    expect(page).to have_content('(09) Ariège')

    expect do
      within first('.organization-attachment') do
        click_link 'Supprimer'
      end
    end.to change(AreasOrganizationsMapping, :count).from(2).to(1)
    expect(page).not_to have_content('(09) Ariège')
  end

  scenario 'An admin attaches jurisdictions to an organization' do
    create :jurisdiction, name: 'Juridiction de Nanterre'
    create :organization, name: 'SPIP 92'
    visit organizations_path
    within first('.organizations-item-container') do
      click_link 'Modifier'
    end
    within '#jurisdiction-form' do
      select 'Juridiction de Nanterre', from: :areas_organizations_mapping_area_id
      expect { click_button 'Ajouter' }.to change(AreasOrganizationsMapping, :count).from(1).to(2)
    end
    expect(page).to have_content('Juridiction de Nanterre')

    expect do
      within all('.organization-attachment').last do
        click_link 'Supprimer'
      end
    end.to change(AreasOrganizationsMapping, :count).from(2).to(1)
  end
end
