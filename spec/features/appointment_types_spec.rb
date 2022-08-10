require 'rails_helper'

RSpec.feature 'AppointmentType', type: :feature do
  before do
    @user = create_admin_user_and_login
  end

  describe 'index' do
    it 'lists all appointment_types' do
      create(:appointment_type, name: 'type 1')
      create(:appointment_type, name: 'type 2')

      visit appointment_types_path

      expect(page).to have_content('type 1')
      expect(page).to have_content('type 2')
    end
  end

  describe 'update' do
    let(:appointment_type) { create(:appointment_type, name: '1er contact') }

    let!(:notif_type1) do
      create(:notification_type, appointment_type: appointment_type, is_default: true,
                                 role: :summon, template: 'Default summon')
    end

    let!(:notif_type2) do
      create(:notification_type, appointment_type: appointment_type, is_default: true,
                                 role: :reminder, template: 'Default reminder')
    end

    let!(:notif_type3) do
      create(:notification_type, appointment_type: appointment_type, is_default: true,
                                 role: :cancelation, template: 'Default cancelation')
    end

    let!(:notif_type4) do
      create(:notification_type, appointment_type: appointment_type, is_default: true,
                                 role: :no_show, template: 'Default no_show')
    end

    let!(:notif_type5) do
      create(:notification_type, appointment_type: appointment_type, is_default: true,
                                 role: :reschedule, template: 'Default reschedule')
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

      within first('.reminder-container') do
        fill_in 'Modèle', with: 'Girl'
      end

      within first('.cancelation-container') do
        fill_in 'Modèle', with: 'Bwah'
      end

      within first('.no-show-container') do
        fill_in 'Modèle', with: 'Dudette'
      end

      click_button 'Enregistrer'

      expect(notif_type1.reload.template).to eq('Yolo')
      expect(notif_type2.reload.template).to eq('Girl')
      expect(notif_type3.reload.template).to eq('Bwah')
      expect(notif_type4.reload.template).to eq('Dudette')

      expect(page).to have_content('Les modifications ont bien été enregistrées.')
    end

    it 'updates local template set', js: true do
      local_notif1 = create :notification_type, appointment_type: appointment_type,
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

    it 'updates local notification_types that stayed default when updating default notification_types', js: true do
      @user.organization.setup_notification_types

      visit edit_appointment_type_path(id: appointment_type.id, orga: @user.organization.id)

      summon_container = first('.summon-container')

      expect(summon_container).to have_content('Défaut')

      within summon_container do
        fill_in 'Modèle', with: 'updated local summon'
      end

      click_button 'Enregistrer'

      visit edit_appointment_type_path(id: appointment_type.id, orga: @user.organization.id)

      expect(first('.summon-container')).to have_content('Personnalisé')
      expect(first('.summon-container')).to have_content('updated local summon')
      expect(first('.reminder-container')).to have_content('Défaut')
      expect(first('.reminder-container')).to have_content('Default reminder')

      visit edit_appointment_type_path(id: appointment_type.id)

      within first('.summon-container') do
        fill_in 'Modèle', with: 'updated default summon'
      end

      within first('.reminder-container') do
        fill_in 'Modèle', with: 'updated default reminder'
      end

      click_button 'Enregistrer'

      visit edit_appointment_type_path(id: appointment_type.id, orga: @user.organization.id)

      expect(first('.summon-container')).to have_content('updated local summon')
      expect(first('.reminder-container')).to have_content('updated default reminder')
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
