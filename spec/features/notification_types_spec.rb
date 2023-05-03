require 'rails_helper'

RSpec.feature 'NotificationType', type: :feature do
  before do
    @user = create_admin_user_and_login
  end

  describe 'Text message construction' do
    it 'uses a local template for an organization', js: true do
      orga1 = create :organization, name: 'SPIP 65'
      orga2 = create :organization, name: 'SPIP 42'

      @user.organization = orga1

      apt_type = create :appointment_type, :with_notification_types, name: 'RDV de suivi SPIP'

      create :notification_type, appointment_type: apt_type,
                                 organization: orga1,
                                 role: :summon,
                                 template: 'Bienvenue au SPIP 65'

      create :notification_type, appointment_type: apt_type,
                                 organization: orga2,
                                 role: :summon,
                                 template: 'Bienvenue au SPIP 42'

      convict = create :convict, first_name: 'JP', last_name: 'Durand'
      create :areas_convicts_mapping, convict: convict, area: orga1.departments.first
      place = create :place, name: 'SPIP 65', appointment_types: [apt_type], organization: orga1
      create :agenda, place: place, name: 'Agenda SPIP 65'

      visit new_appointment_path

      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'DURAND Jp').click

      select 'RDV de suivi SPIP', from: :appointment_appointment_type_id
      select 'SPIP 65', from: 'Lieu'

      fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

      within first('.form-time-select-fields') do
        select '15', from: 'appointment_slot_starting_time_4i'
        select '00', from: 'appointment_slot_starting_time_5i'
      end

      click_button 'Enregistrer'

      expect { click_button 'Oui' }.to change { Appointment.count }.by(1)

      notif = Notification.find_by(role: :summon, appointment: convict.appointments.last)

      expect(notif.content).to eq('Bienvenue au SPIP 65')
    end
  end
end
