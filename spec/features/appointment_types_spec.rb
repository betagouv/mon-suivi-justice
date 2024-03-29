require 'rails_helper'

RSpec.feature 'AppointmentType', type: :feature do
  describe 'index', logged_in_as: 'admin' do
    it 'lists all appointment_types' do
      create(:appointment_type, name: 'type 1')
      create(:appointment_type, name: 'type 2')

      visit appointment_types_path

      expect(page).to have_content('type 1')
      expect(page).to have_content('type 2')
    end
  end

  describe 'update', logged_in_as: 'admin' do
    let!(:organization) { create(:organization, name: 'SPIP 92') }
    let!(:appointment_type) { create(:appointment_type, name: '1er contact') }

    let!(:notif_type1) do
      create(:notification_type, appointment_type:, organization: nil, is_default: true,
                                 role: :summon, template: 'Default summon')
    end

    let!(:notif_type2) do
      create(:notification_type, appointment_type:, organization: nil, is_default: true,
                                 role: :reminder, template: 'Default reminder')
    end

    it 'updates default template set', js: true do
      visit appointment_types_path

      select 'Défaut', from: :orga
      page.execute_script("$('#apt-type-organization-select').trigger('change')")
      page.driver.browser.navigate.refresh

      within first('.index-controls-container') do
        click_link 'Modifier'
      end

      expect(page).to have_content('Modifier modèles')

      within first('.summon-container') do
        fill_in 'Modèle', with: 'Yolo'
      end

      click_button 'Enregistrer'

      expect(notif_type1.reload.template).to eq('Yolo')

      expect(page).to have_content('Les modifications ont bien été enregistrées.')
    end

    it 'updates local template set', js: true do
      local_notif1 = create :notification_type, appointment_type:,
                                                organization: @user.organization,
                                                role: :summon,
                                                template: 'Local summon'

      visit appointment_types_path

      select @user.organization.name, from: :orga
      page.execute_script("$('#apt-type-organization-select').trigger('change')")
      expect(page).to have_current_path(appointment_types_path(orga: @user.organization.id))
      page.driver.browser.navigate.refresh

      within first('.appointment-types-item-container') do
        click_link 'Modifier'
      end

      within first('.summon-container') do
        fill_in 'Modèle', with: 'updated local summon'
      end

      click_button 'Enregistrer'

      expect(local_notif1.reload.template).to eq('updated local summon')
    end

    it 'allows to reset notification type to default' do
      local_notif = create :notification_type, appointment_type:,
                                               organization: @user.organization,
                                               role: :summon,
                                               template: 'Local summon',
                                               is_default: false,
                                               still_default: false

      visit edit_appointment_type_path(appointment_type, orga: @user.organization.id)

      within first('.summon-container') do
        click_link 'Restaurer défaut'
      end

      click_button 'Enregistrer'

      expect(local_notif.reload.template).to eq('Default summon')
    end

    it 'does not allow to update notification types with incorrect template' do
      visit edit_appointment_type_path(appointment_type)

      within first('.summon-container') do
        fill_in 'Modèle', with: 'Mince {incorrect_key}'
      end

      click_button 'Enregistrer'

      notif_type1.reload
      expect(notif_type1.template).to eq('Default summon')

      expected_content = "Le format de ce modèle n'est pas valide. " \
                         "Merci d'utiliser uniquement les clés documentées."
      expect(page).to have_content(expected_content)
    end
  end
end
