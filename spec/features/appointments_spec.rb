require 'rails_helper'

RSpec.feature 'Appointments', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    before do
      slot1 = create(:slot, date: '06/06/2021', starting_time: new_time_for(13, 0))
      slot2 = create(:slot, date: '08/08/2021', starting_time: new_time_for(15, 30))

      create(:appointment, slot: slot1)
      create(:appointment, slot: slot2)

      visit appointments_path
    end

    it 'lists all appointments' do
      expect(page).to have_content('06/06/2021')
      expect(page).to have_content('13:00')
      expect(page).to have_content('08/08/2021')
      expect(page).to have_content('15:30')
    end

    it 'allows to filter appointments' do
      expect(page).to have_content('06/06/2021')

      fill_in 'search-field', with: '08/08/2021'
      click_button 'Filtrer'

      expect(page).not_to have_content('06/06/2021')
    end
  end

  describe 'JAP appointments index', js: true do
    it 'lists all appointments' do
      convict1 = create(:convict, first_name: 'James',
                                  last_name: 'Moriarty',
                                  prosecutor_number: '203204')

      convict2 = create(:convict, first_name: 'Lex',
                                  last_name: 'Luthor',
                                  prosecutor_number: '205206')

      apt_type = create(:appointment_type, name: 'RDV BEX SAP')
      place = create(:place, place_type: 'sap', name: 'Tribunal de Nanterre')

      agenda1 = create(:agenda, place: place, name: 'Cabinet 1')
      agenda2 = create(:agenda, place: place, name: 'Cabinet 2')

      slot1 = create(:slot, agenda: agenda1,
                            appointment_type: apt_type,
                            date: Date.today.next_occurring(:friday),
                            starting_time: '10h')

      slot2 = create(:slot, agenda: agenda2,
                            appointment_type: apt_type,
                            date: Date.today.next_occurring(:friday),
                            starting_time: '11h')

      current_date = slot1.date.strftime('%d/%m/%Y')

      create(:appointment, slot: slot1, convict: convict1)
      create(:appointment, slot: slot2, convict: convict2)

      bex_user = create(:user, role: :bex)
      logout_current_user
      login_user(bex_user)

      visit appointments_path
      click_button 'Agenda RDV JAP'

      expect(page).to have_current_path(jap_appointments_path)

      select current_date, from: :date
      page.execute_script("$('#jap-appointments-date-select').trigger('change')")

      expect(page).to have_current_path(jap_appointments_path(date: current_date))

      agenda_containers = page.all('.jap-agenda-container')

      expect(agenda_containers[0]).to have_content('Cabinet 1')
      expect(agenda_containers[0]).to have_content('James')
      expect(agenda_containers[0]).to have_content('Moriarty')

      expect(agenda_containers[1]).to have_content('Cabinet 2')
      expect(agenda_containers[1]).to have_content('Lex')
      expect(agenda_containers[1]).to have_content('Luthor')
    end
  end

  describe 'creation', js: true do
    it 'works' do
      create(:convict, first_name: 'JP', last_name: 'Cherty')
      place = create(:place, name: 'KFC de Chatelet', place_type: 'sap')
      appointment_type = create(:appointment_type, name: 'RDV suivi SAP', place_type: 'sap')
      agenda = create(:agenda, place: place, name: 'Agenda de Josiane')
      create(:agenda, place: place, name: 'Agenda de Michel')

      create(:slot, agenda: agenda,
                    appointment_type: appointment_type,
                    date: '10/10/2021', starting_time: '16h')

      create(:notification_type, appointment_type: appointment_type)

      visit new_appointment_path

      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'CHERTY Jp').click

      select 'RDV suivi SAP', from: 'Type de rendez-vous'
      select 'KFC de Chatelet', from: 'Lieu'
      select 'Agenda de Josiane', from: 'Agenda'

      choose '16:00'

      expect(page).to have_button('Enregistrer')
      expect { click_button 'Enregistrer' }.to change { Appointment.count }.by(1)
                                           .and change { Notification.count }.by(1)
    end
  end
end
