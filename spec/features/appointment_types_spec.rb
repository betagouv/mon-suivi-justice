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
    before do
      @appointment_type = create(:appointment_type, name: '1er contact')
    end

    it 'allows to update notification types' do
      notif_type1 = create(:notification_type, appointment_type: @appointment_type,
                                               role: :summon,
                                               template: 'Yo')
      notif_type2 = create(:notification_type, appointment_type: @appointment_type,
                                               role: :reminder,
                                               template: 'Man')
      notif_type3 = create(:notification_type, appointment_type: @appointment_type,
                                               role: :cancelation,
                                               template: 'Bruh')
      notif_type4 = create(:notification_type, appointment_type: @appointment_type,
                                               role: :no_show,
                                               template: 'Dude')
      create(:notification_type, appointment_type: @appointment_type,
                                 role: :reschedule,
                                 template: 'Meh')

      visit edit_appointment_type_path(@appointment_type)

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
    end
  end
end
