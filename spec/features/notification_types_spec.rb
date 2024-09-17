require 'rails_helper'

RSpec.feature 'NotificationType', type: :feature do
  describe 'Text message construction', logged_in_as: 'admin' do
    it 'uses a local template for an organization', js: true do
      @user.organization.name = 'SPIP 65'

      orga2 = create :organization, name: 'SPIP 42'

      apt_type = create :appointment_type, name: 'Convocation de suivi SPIP'

      create :notification_type, appointment_type: apt_type,
                                 organization: @user.organization,
                                 role: :reminder,
                                 template: 'Bienvenue au SPIP 65'
      create :notification_type, appointment_type: apt_type,
                                 organization: @user.organization,
                                 role: :summon,
                                 template: 'Bienvenue au SPIP 65'

      create :notification_type, appointment_type: apt_type,
                                 organization: orga2,
                                 role: :summon,
                                 template: 'Bienvenue au SPIP 42'

      convict = create :convict, first_name: 'JP', last_name: 'Durand', organizations: [@user.organization]
      place = create :place, name: 'SPIP 65', appointment_types: [apt_type], organization: @user.organization
      create :agenda, place:, name: 'Agenda SPIP 65'

      visit new_appointment_path({ convict_id: convict.id })

      select 'Convocation de suivi SPIP', from: :appointment_appointment_type_id
      select 'SPIP 65', from: 'Lieu'

      fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

      within first('.form-time-select-fields') do
        select '15', from: 'appointment_slot_starting_time_4i'
        select '00', from: 'appointment_slot_starting_time_5i'
      end

      page.find('label[for="send_sms_1"]').click

      expect { click_button 'Convoquer' }.to change { Appointment.count }.by(1)

      notif = Notification.find_by(role: :summon, appointment: convict.appointments.last)

      expect(notif.content).to eq('Bienvenue au SPIP 65')
    end
  end
end
