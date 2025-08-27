require 'rails_helper'

RSpec.feature 'Organizations', type: :feature, logged_in_as: 'admin' do
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
    expect(page).to have_content('Modifier le service')
    name_field = find(:css, 'input[name="organization[name]"][disabled]')
    expect(name_field.value).to eq('SPIP 75')
    #expect(page).to have_field('Nom', with: 'SPIP 75')
  end

  scenario 'An admin updates an organization', js: true do
    # Create an organization with the specified name
    organization = create :organization, name: 'SPIP 92'
    visit organizations_path

    # Click on the 'Edit' link in the first row of the table
    within find("tr", text: organization.name) do
      click_link 'Modifier'
    end

    # Find the disabled field and check its initial value
    name_field = find(:css, 'input[name="organization[name]"]')
    expect(name_field[:disabled]).to be_truthy

    # Check that the value of the field is indeed the expected one
    expect(name_field.value).to eq('SPIP 92')

    # Réactivez temporairement le champ en utilisant JavaScript
    page.execute_script("document.querySelector('input[name=\"organization[name]\"]').removeAttribute('disabled');")
    fill_in :organization_name, with: 'SPIP 75'

    expect(name_field.value).to eq('SPIP 75')
    
    click_button 'Enregistrer'
    expect(page).to have_content('Modifier le service')
    expect(name_field.value).to eq('SPIP 92')
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

  scenario 'An admin adds an extra field to an organization', js: true, logged_in_as: 'admin' do
    organization = create :organization, organization_type: 'tj'
    @user.update(organization:)
    place = create :place, organization: @user.organization
    agenda = create(:agenda, place:)

    apt_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                   name: "Sortie d'audience SAP")

    create(:slot, :without_validations, agenda:,
                                        date: Date.civil(2025, 4, 14),
                                        appointment_type: apt_type,
                                        starting_time: new_time_for(13, 0))

    visit edit_organization_path(@user.organization)

    # Check that the button is present and click on it
    expect(page).to have_button('Ajouter une colonne')
    click_button 'Ajouter une colonne'

    # Fill in the field for the new extra field
    fill_in 'Nom de la colonne', with: 'Colonne de test'

    # Check and tick the box for the type of appointment
    expect(page).to have_field("Sortie d'audience SAP")
    page.check "Sortie d'audience SAP"

    # Submit the form and check the change
    expect { click_button 'Enregistrer' }.to change { ExtraField.count }.by(1)
  end
end
