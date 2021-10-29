require 'rails_helper'

RSpec.feature 'Appointments', type: :feature do
  before { create_admin_user_and_login }

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

    it "doesn't show canceled appointments" do
      convict = create(:convict, last_name: 'Gomez')
      apt_type = create(:appointment_type, :with_notification_types, name: 'RDV BEX SPIP')
      slot = create(:slot, date: Date.today, appointment_type: apt_type, starting_time: new_time_for(14, 0))
      appointment = create(:appointment, :with_notifications, convict: convict, slot: slot)

      appointment.book

      visit appointments_path
      expect(page).to have_content('GOMEZ')

      visit today_appointments_path
      expect(page).to have_content('GOMEZ')

      visit agenda_spip_path
      expect(page).to have_content('GOMEZ')

      appointment.cancel

      visit appointments_path
      expect(page).not_to have_content('GOMEZ')

      visit today_appointments_path
      expect(page).not_to have_content('GOMEZ')

      visit agenda_spip_path
      expect(page).not_to have_content('GOMEZ')
    end
  end

  describe 'creation', js: true do
    let(:frozen_date) { Date.new 2015, 5, 5 }

    before { allow(Date).to receive(:today).and_return frozen_date }

    it 'create an appointment with a convocation sms' do
      create(:convict, first_name: 'JP', last_name: 'Cherty')
      appointment_type = create :appointment_type, :with_notification_types, name: 'RDV suivi SAP'
      place = create :place, name: 'KFC de Chatelet', appointment_types: [appointment_type]
      agenda = create :agenda, place: place, name: 'Agenda de Josiane'
      create :agenda, place: place, name: 'Agenda de Michel'

      slot = create :slot, agenda: agenda,
                           appointment_type: appointment_type,
                           date: (Date.today + 2).to_s,
                           starting_time: '16h'

      visit new_appointment_path
      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'CHERTY Jp').click
      select 'RDV suivi SAP', from: 'Type de rendez-vous'
      select 'KFC de Chatelet', from: 'Lieu'
      select 'Agenda de Josiane', from: 'Agenda'
      choose '16:00'
      expect(page).to have_button('Enregistrer')
      click_button 'Enregistrer'
      expect { click_button 'Oui' }.to change { Appointment.count }.by(1).and change { Notification.count }.by(4)
      expect(SmsDeliveryJob).to have_been_enqueued.once.with(
        Notification.find_by(role: :summon, appointment: Appointment.find_by(slot: slot))
      )
      expect(SmsDeliveryJob).to have_been_enqueued.once.with(
        Notification.find_by(role: :reminder, appointment: Appointment.find_by(slot: slot))
      )
    end

    it 'create an appointment without a convocation sms' do
      create(:convict, first_name: 'JP', last_name: 'Cherty')
      appointment_type = create :appointment_type, :with_notification_types, name: 'RDV suivi SAP'
      place = create :place, name: 'KFC de Chatelet', appointment_types: [appointment_type]
      agenda = create :agenda, place: place, name: 'Agenda de Josiane'
      create :agenda, place: place, name: 'Agenda de Michel'

      slot = create :slot, agenda: agenda,
                           appointment_type: appointment_type,
                           date: (Date.today + 2).to_s,
                           starting_time: '16h'

      visit new_appointment_path
      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'CHERTY Jp').click
      select 'RDV suivi SAP', from: 'Type de rendez-vous'
      select 'KFC de Chatelet', from: 'Lieu'
      select 'Agenda de Josiane', from: 'Agenda'
      choose '16:00'
      expect(page).to have_button('Enregistrer')
      click_button 'Enregistrer'
      expect { click_button 'Non' }.to change { Appointment.count }.by(1).and change { Notification.count }.by(4)
      expect(SmsDeliveryJob).to have_been_enqueued.once.with(
        Notification.find_by(role: :reminder, appointment: Appointment.find_by(slot: slot))
      )
    end

    it 'allows an agent to create appointment only for his service places & slots', js: true do
      department = create :department, number: '09', name: 'Ariège'
      logout_current_user
      organization = create :organization
      create :areas_organizations_mapping, organization: organization, area: department
      agent = create :user, role: :cpip, organization: organization
      login_user agent
      convict = create :convict, first_name: 'JP', last_name: 'Cherty'
      create :areas_convicts_mapping, convict: convict, area: department
      appointment_type = create :appointment_type, :with_notification_types, name: 'RDV suivi SAP'
      place_in = create :place, organization: organization, name: 'place_in_name', appointment_types: [appointment_type]
      agenda_in = create :agenda, place: place_in, name: 'agenda_in_name'
      create :agenda, place: place_in, name: 'other_agenda_in_name'

      create :place, name: 'place_out_name', appointment_types: [appointment_type]
      agenda_out = create :agenda, name: 'agenda_out_name'

      create :slot, agenda: agenda_in, appointment_type: appointment_type, date: '10/10/2021', starting_time: '14h'
      create :slot, agenda: agenda_out, appointment_type: appointment_type, date: '10/10/2021', starting_time: '16h'

      visit new_appointment_path
      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'CHERTY Jp').click
      select 'RDV suivi SAP', from: 'Type de rendez-vous'
      expect(page).not_to have_select('Lieu', options: ['', 'place_in_name', 'place_out_name'])
      expect(page).to have_select('Lieu', options: ['', 'place_in_name'])
      select 'place_in_name', from: 'Lieu'
      expect(page).not_to have_select('Agenda',
                                      options: ['', 'agenda_in_name', 'agenda_out_name', 'other_agenda_in_name'])
      expect(page).to have_select('Agenda', options: ['', 'agenda_in_name', 'other_agenda_in_name'])
      select 'agenda_in_name', from: 'Agenda'
      choose '14:00'
      expect(page).to have_button('Enregistrer')
      click_button 'Enregistrer'
      expect { click_button 'Oui' }.to change { Appointment.count }.by(1)
                                           .and change { Notification.count }.by(4)
    end

    it 'shows only relevant places for an appointment type', js: true do
      create(:convict, first_name: 'Joe', last_name: 'Dalton')

      apt_type1 = create(:appointment_type, name: 'RDV de test SAP')
      apt_type2 = create(:appointment_type, name: 'RDV de test SPIP')

      create(:place, name: 'McDo de Barbès', appointment_types: [apt_type1])
      create(:place, name: 'Quick de Montreuil', appointment_types: [apt_type2])

      visit new_appointment_path

      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'DALTON Joe').click

      select 'RDV de test SAP', from: 'Type de rendez-vous'

      expect(page).not_to have_select('Lieu', options: ['', 'McDo de Barbès', 'Quick de Montreuil'])
      expect(page).to have_select('Lieu', options: ['', 'McDo de Barbès'])
    end
  end

  describe 'show' do
    it 'displays appointment data' do
      slot = create(:slot, date: '06/10/2021', starting_time: new_time_for(17, 0))
      convict = create(:convict, first_name: 'Monique', last_name: 'Lassalle')

      appointment = create(:appointment, slot: slot, convict: convict)

      visit appointment_path(appointment)

      expect(page).to have_content('06/10/2021')
      expect(page).to have_content('17:00')
      expect(page).to have_content('Monique')
      expect(page).to have_content('LASSALLE')
    end
  end

  describe 'cancelation' do
    it 'change state and cancel notifications' do
      apt_type = create(:appointment_type, :with_notification_types)
      appointment = create(:appointment, appointment_type: apt_type)

      appointment.book
      expect(appointment.state).to eq('booked')
      expect(appointment.notifications.count).to eq(4)
      expect(appointment.reminder_notif.state).to eq('programmed')
      expect(appointment.cancelation_notif.state).to eq('created')

      visit appointment_path(appointment)

      click_button 'Annuler'

      appointment.reload
      expect(appointment.state).to eq('canceled')
      expect(appointment.reminder_notif.state).to eq('canceled')
      expect(appointment.cancelation_notif.state).to eq('sent')

      expect(page).to have_current_path(appointment_path(appointment))
    end

    it 'cant cancel a not-booked appointment' do
      visit appointment_path(create(:appointment))
      expect(page).not_to have_button 'Annuler'
    end
  end

  describe 'fulfilment' do
    it 'controls are only displayed for passed appointments' do
      convict = create(:convict)
      apt_type = create(:appointment_type, :with_notification_types)
      slot = create(:slot, date: Date.tomorrow)

      appointment = create(:appointment, convict: convict,
                                         slot: slot,
                                         appointment_type: apt_type)

      appointment.book

      visit convict_path(convict)

      expect(page).not_to have_selector '.appointment-fulfilment-container'
    end

    it 'works if convict came to appointment' do
      convict = create(:convict)
      apt_type = create(:appointment_type, :with_notification_types)
      slot = create(:slot, date: Date.today)

      appointment = create(:appointment, convict: convict,
                                         slot: slot,
                                         appointment_type: apt_type)

      appointment.book

      visit convict_path(convict)
      within first('.appointment-fulfilment-container') { find('#show-convict-fulfil-button').click }

      appointment.reload
      expect(appointment.state).to eq('fulfiled')
    end

    it 'is also available on appointment#show page' do
      convict = create(:convict)
      apt_type = create(:appointment_type, :with_notification_types)
      slot = create(:slot, date: Date.today)

      appointment = create(:appointment, convict: convict,
                                         slot: slot,
                                         appointment_type: apt_type)

      appointment.book

      visit appointment_path(appointment)
      within first('.appointment-fulfilment-container') { find('#show-convict-fulfil-button').click }

      appointment.reload
      expect(appointment.state).to eq('fulfiled')
    end

    describe "if convict didn't came to appointment" do
      it 'change appointment state and sends sms', js: true do
        convict = create(:convict, first_name: 'babar', last_name: 'bobor')
        apt_type = create(:appointment_type, :with_notification_types)
        slot = create(:slot, date: Date.today)

        appointment = create(:appointment, convict: convict,
                                           slot: slot,
                                           appointment_type: apt_type)

        appointment.book

        visit convict_path(convict)

        within first('.appointment-fulfilment-container') { click_button 'Non' }
        within("#missed-appointment-modal-#{appointment.id}") { click_button 'Oui' }

        appointment.reload
        expect(appointment.state).to eq('no_show')
        expect(SmsDeliveryJob).to have_been_enqueued.once.with(appointment.no_show_notif)
      end

      it "change appointment state and don't send sms", js: true do
        convict = create(:convict, first_name: 'babar', last_name: 'bobor')
        apt_type = create(:appointment_type, :with_notification_types)
        slot = create(:slot, date: Date.today)

        appointment = create(:appointment, convict: convict,
                                           slot: slot,
                                           appointment_type: apt_type)

        appointment.book

        visit convict_path(convict)

        within first('.appointment-fulfilment-container') { click_button 'Non' }
        within("#missed-appointment-modal-#{appointment.id}") { click_button 'Non' }

        appointment.reload
        expect(appointment.state).to eq('no_show')
        expect(SmsDeliveryJob).not_to have_been_enqueued.with(appointment.no_show_notif)
      end

      it 'can be excused' do
        convict = create(:convict)
        apt_type = create(:appointment_type, :with_notification_types)

        appointment = create(:appointment, convict: convict,
                                           appointment_type: apt_type)

        appointment.book

        visit convict_path(convict)

        within first('.appointment-fulfilment-container') { click_button 'Excusé(e)' }

        appointment.reload
        expect(appointment.state).to eq('excused')
      end
    end
  end
end
