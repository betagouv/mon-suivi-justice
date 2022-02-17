require 'rails_helper'

RSpec.feature 'AppointmentType', type: :feature do
  before do
    create_admin_user_and_login
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
      create(:notification_type, appointment_type: appointment_type,
                                 role: :summon, template: 'Yo')
    end
    let!(:notif_type2) do
      create(:notification_type, appointment_type: appointment_type,
                                 role: :reminder, template: 'Man')
    end
    let!(:notif_type3) do
      create(:notification_type, appointment_type: appointment_type,
                                 role: :cancelation, template: 'Bruh')
    end
    let!(:notif_type4) do
      create(:notification_type, appointment_type: appointment_type,
                                 role: :no_show, template: 'Dude')
    end
    let!(:notif_type5) do
      create(:notification_type, appointment_type: appointment_type,
                                 role: :reschedule, template: 'Meh')
    end

    it 'allows to update notification types' do
      visit edit_appointment_type_path(appointment_type)

      within first('.summon-container') do
        fill_in 'Template', with: 'Yolo'
      end

      within first('.reminder-container') do
        fill_in 'Template', with: 'Girl'
      end

      within first('.cancelation-container') do
        fill_in 'Template', with: 'Bwah'
      end

      within first('.no-show-container') do
        fill_in 'Template', with: 'Dudette'
      end

      click_button 'Enregistrer'

      notif_type1.reload
      expect(notif_type1.template).to eq('Yolo')

      notif_type2.reload
      expect(notif_type2.template).to eq('Girl')

      notif_type3.reload
      expect(notif_type3.template).to eq('Bwah')

      notif_type4.reload
      expect(notif_type4.template).to eq('Dudette')

      expect(page).to have_content('Les modifications ont bien été enregistrées.')
    end

    it 'does not allow to update notification types with incorrect template' do
      visit edit_appointment_type_path(appointment_type)

      within first('.summon-container') do
        fill_in 'Template', with: 'Mince {incorrect_key}'
      end

      click_button 'Enregistrer'

      notif_type1.reload
      expect(notif_type1.template).to eq('Yo')

      expected_content = "Le format de ce modèle n'est pas valide. " \
                         "Merci d'utiliser uniquement les clés documentées."
      expect(page).to have_content(expected_content)
    end
  end
end
