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

  describe 'creation', js: true do
    it 'works' do
      create(:convict, first_name: 'JP', last_name: 'Cherty')
      place = create(:place, name: 'KFC de Chatelet', place_type: 'sap')

      appointment_type = create(:appointment_type, :with_notification_types,
                                name: 'RDV suivi SAP',
                                place_type: 'sap')

      agenda = create(:agenda, place: place, name: 'Agenda de Josiane')
      create(:agenda, place: place, name: 'Agenda de Michel')

      create(:slot, agenda: agenda,
                    appointment_type: appointment_type,
                    date: '10/10/2021', starting_time: '16h')

      visit new_appointment_path

      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'CHERTY Jp').click

      select 'RDV suivi SAP', from: 'Type de rendez-vous'
      select 'KFC de Chatelet', from: 'Lieu'
      select 'Agenda de Josiane', from: 'Agenda'

      choose '16:00'

      expect(page).to have_button('Enregistrer')
      expect { click_button 'Enregistrer' }.to change { Appointment.count }.by(1)
                                           .and change { Notification.count }.by(4)
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
      expect(page).to have_content 'Ce rendez-vous ne peut-être annulé.'
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
    end
  end
end
