require 'rails_helper'

RSpec.feature 'Appointments', type: :feature do
  before do
    @user = create_admin_user_and_login
    allow(Place).to receive(:in_department).and_return(Place.all)
  end

  describe 'index' do
    before do
      place = create :place, organization: @user.organization
      @agenda = create :agenda, place: place

      @slot1 = create(:slot, agenda: @agenda,
                             date: Date.today.next_occurring(:monday),
                             starting_time: new_time_for(13, 0))
      slot2 = create(:slot, agenda: @agenda,
                            date: Date.today.next_occurring(:wednesday),
                            starting_time: new_time_for(15, 30))
      convict = create(:convict)
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      @appointment1 = create(:appointment, :with_notifications, convict: convict, slot: @slot1)
      create(:appointment, convict: convict, slot: slot2)
    end

    it 'display all appointments' do
      visit appointments_path

      expect(page).to have_content(Date.today.next_occurring(:monday))
      expect(page).to have_content('13:00')
      expect(page).to have_content(Date.today.next_occurring(:wednesday))
      expect(page).to have_content('15:30')
    end

    it 'allows to filter appointments' do
      visit appointments_path

      fill_in 'index-appointment-date-filter', with: Date.today.next_occurring(:wednesday)
      click_button 'Filtrer'

      expect(page).to have_content(Date.today.next_occurring(:wednesday))
      expect(page).not_to have_content(Date.today.next_occurring(:monday))
    end

    it "doesn't show canceled appointments" do
      convict = create(:convict, last_name: 'Gomez')
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      apt_type = create(:appointment_type, :with_notification_types, name: "Sortie d'audience SPIP")
      slot = create(:slot, date: Date.today.next_occurring(:monday),
                           agenda: @agenda,
                           appointment_type: apt_type,
                           starting_time: new_time_for(14, 0))
      appointment = create(:appointment, :with_notifications, convict: convict, slot: slot)

      appointment.book
      visit appointments_path

      expect(page).to have_content('GOMEZ')

      appointment.cancel

      visit appointments_path
      expect(page).not_to have_content('GOMEZ')
    end

    it 'allows to indicate the state of appointments' do
      @slot1.update(date: Date.today.prev_occurring(:monday))
      @appointment1.book

      visit appointments_path

      within first('.index-list-controls-container') do
        click_button 'Honoré'
      end

      @appointment1.reload
      expect(@appointment1.state).to eq('fulfiled')
    end
  end

  describe 'creation', js: true do
    context 'appointment_type with predifined slots' do
      it 'create an appointment with a convocation sms' do
        convict = create(:convict, first_name: 'JP', last_name: 'Cherty')
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

        appointment_type = create :appointment_type, :with_notification_types, name: "Sortie d'audience SAP"
        place = create :place, name: 'KFC de Chatelet', appointment_types: [appointment_type],
                               organization: @user.organization
        agenda = create :agenda, place: place, name: 'Agenda de Josiane'
        create :agenda, place: place, name: 'Agenda de Michel'
        slot = create :slot, agenda: agenda,
                             appointment_type: appointment_type,
                             date: Date.today.next_occurring(:monday),
                             starting_time: '16h'

        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'CHERTY Jp').click
        select "Sortie d'audience SAP", from: :appointment_appointment_type_id
        select 'KFC de Chatelet', from: 'Lieu'
        select 'Agenda de Josiane', from: 'Agenda'
        choose '16:00'

        expect(page).to have_button('Enregistrer')
        click_button 'Enregistrer'

        expect { click_button 'Oui' }.to change { Appointment.count }.by(1).and change { Notification.count }.by(5)

        expect(SmsDeliveryJob).to have_been_enqueued.once.with(
          Notification.find_by(role: :summon, appointment: Appointment.find_by(slot: slot))
        )

        expect(SmsDeliveryJob).to have_been_enqueued.once.with(
          Notification.find_by(role: :reminder, appointment: Appointment.find_by(slot: slot))
        )
      end

      it 'create an appointment without a convocation sms' do
        convict = create(:convict, first_name: 'JP', last_name: 'Cherty')
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
        appointment_type = create :appointment_type, :with_notification_types, name: "Sortie d'audience SAP"
        place = create :place, name: 'KFC de Chatelet', appointment_types: [appointment_type],
                               organization: @user.organization
        agenda = create :agenda, place: place, name: 'Agenda de Josiane'
        create :agenda, place: place, name: 'Agenda de Michel'

        slot = create :slot, agenda: agenda,
                             appointment_type: appointment_type,
                             date: Date.today.next_occurring(:monday),
                             starting_time: '16h'

        visit new_appointment_path
        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'CHERTY Jp').click
        select "Sortie d'audience SAP", from: :appointment_appointment_type_id
        select 'KFC de Chatelet', from: 'Lieu'
        select 'Agenda de Josiane', from: 'Agenda'
        choose '16:00'

        expect(page).to have_button('Enregistrer')

        click_button 'Enregistrer'

        expect { click_button 'Non' }.to change { Appointment.count }.by(1).and change { Notification.count }.by(5)
        expect(SmsDeliveryJob).to have_been_enqueued.once.with(
          Notification.find_by(role: :reminder, appointment: Appointment.find_by(slot: slot))
        )
      end

      it 'allows an agent to create appointment only for his service places & slots' do
        department = create :department, number: '09', name: 'Ariège'
        logout_current_user
        organization = create :organization
        create :areas_organizations_mapping, organization: organization, area: department
        agent = create :user, role: :cpip, organization: organization
        login_user agent

        convict = create :convict, first_name: 'JP', last_name: 'Cherty'
        create :areas_convicts_mapping, convict: convict, area: department
        appointment_type = create :appointment_type, :with_notification_types, name: "Sortie d'audience SPIP"

        place_in = create :place, organization: organization, name: 'place_in_name',
                                  appointment_types: [appointment_type]
        agenda_in = create :agenda, place: place_in, name: 'agenda_in_name'
        create :agenda, place: place_in, name: 'other_agenda_in_name'

        create :place, name: 'place_out_name', appointment_types: [appointment_type]
        agenda_out = create :agenda, name: 'agenda_out_name'

        create :slot, agenda: agenda_in, appointment_type: appointment_type, date: Date.today.next_occurring(:friday),
                      starting_time: '14h'
        create :slot, agenda: agenda_out, appointment_type: appointment_type, date: Date.today.next_occurring(:friday),
                      starting_time: '16h'

        visit new_appointment_path
        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'CHERTY Jp').click
        select "Sortie d'audience SPIP", from: :appointment_appointment_type_id
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
                                            .and change { Notification.count }.by(5)
      end

      it 'shows only relevant places for an appointment type' do
        convict = create(:convict, first_name: 'Joe', last_name: 'Dalton')
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

        apt_type1 = create(:appointment_type, name: 'RDV de test SAP')
        apt_type2 = create(:appointment_type, name: 'RDV de test SPIP')

        create(:place, name: 'McDo de Barbès', appointment_types: [apt_type1])
        create(:place, name: 'Quick de Montreuil', appointment_types: [apt_type2])

        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'DALTON Joe').click

        select 'RDV de test SAP', from: :appointment_appointment_type_id

        expect(page).not_to have_select('Lieu', options: ['', 'McDo de Barbès', 'Quick de Montreuil'])
        expect(page).to have_select('Lieu', options: ['', 'McDo de Barbès'])
      end
    end

    context 'appointment_type without predefined slots' do
      before do
        convict = create :convict, first_name: 'Momo', last_name: 'La Fouine'
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
        appointment_type = create :appointment_type, :with_notification_types, name: 'RDV de suivi SAP'
        place = create :place, name: 'McDo des Halles', appointment_types: [appointment_type],
                               organization: @user.organization
        create :agenda, place: place, name: 'Agenda de Jean-Louis'
        create :agenda, place: place, name: 'Agenda de Mireille'
      end

      it 'creates an appointment' do
        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'LA FOUINE Momo').click

        select 'RDV de suivi SAP', from: :appointment_appointment_type_id
        select 'McDo des Halles', from: 'Lieu'
        select 'Agenda de Jean-Louis', from: 'Agenda'

        fill_in 'appointment_slot_date', with: (Date.today.next_occurring(:friday)).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        click_button 'Enregistrer'

        expect { click_button 'Oui' }.to change { Appointment.count }.by(1)
                                    .and change { Slot.count }.by(1)
                                    .and change { Notification.count }.by(5)
      end

      it 'does not create appointment if the selected date is a weekend' do
        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'LA FOUINE Momo').click

        select 'RDV de suivi SAP', from: :appointment_appointment_type_id
        select 'McDo des Halles', from: 'Lieu'
        select 'Agenda de Jean-Louis', from: 'Agenda'

        fill_in 'appointment_slot_date', with: (Date.today.next_occurring(:saturday)).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        click_button 'Enregistrer'

        expect { click_button 'Oui' }.to change { Appointment.count }.by(0)
                                    .and change { Slot.count }.by(0)
                                    .and change { Notification.count }.by(0)

        expect(page).to have_content("Le jour sélectionné n'est pas un jour ouvrable")
      end
    end
  end

  describe 'show' do
    it 'displays appointment data' do
      slot = create(:slot, date: Date.today.next_occurring(:wednesday), starting_time: new_time_for(17, 0))
      convict = create(:convict, first_name: 'Monique', last_name: 'Lassalle')
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      appointment = create(:appointment, :with_notifications, slot: slot, convict: convict)

      visit appointment_path(appointment)

      expect(page).to have_content(Date.today.next_occurring(:wednesday))
      expect(page).to have_content('17:00')
      expect(page).to have_content('Monique')
      expect(page).to have_content('LASSALLE')
    end
  end

  describe 'cancelation' do
    before do
      @convict = create(:convict)
      create :areas_convicts_mapping, convict: @convict, area: @user.organization.departments.first
    end

    it 'change state and cancel notifications' do
      apt_type = create(:appointment_type, :with_notification_types)
      slot = create :slot, appointment_type: apt_type

      appointment = create(:appointment, convict: @convict, slot: slot)

      appointment.book
      expect(appointment.state).to eq('booked')
      expect(appointment.notifications.count).to eq(5)
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
      appointment = create :appointment, :with_notifications, convict: @convict
      visit appointment_path(appointment)
      expect(page).not_to have_button 'Annuler'
    end
  end

  describe 'fulfilment' do
    it 'controls are only displayed for passed appointments' do
      convict = create :convict
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      apt_type = create :appointment_type, :with_notification_types
      slot = create :slot, date: Date.today.next_occurring(:monday), appointment_type: apt_type
      appointment = create :appointment, convict: convict, slot: slot

      appointment.book

      visit convict_path(convict)

      expect(page).not_to have_selector '.appointment-fulfilment-container'
    end

    it 'works if convict came to appointment' do
      convict = create :convict
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
      apt_type = create :appointment_type, :with_notification_types
      slot = create :slot, date: Date.today, appointment_type: apt_type
      appointment = create :appointment, convict: convict, slot: slot

      appointment.book

      visit convict_path(convict)
      within first('.appointment-fulfilment-container') { find('#show-convict-fulfil-button').click }

      appointment.reload
      expect(appointment.state).to eq('fulfiled')
    end

    it 'is also available on appointment#show page' do
      convict = create :convict
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      apt_type = create :appointment_type, :with_notification_types
      slot = create :slot, date: Date.today, appointment_type: apt_type
      appointment = create :appointment, convict: convict, slot: slot

      appointment.book

      visit appointment_path(appointment)
      within first('.appointment-fulfilment-container') { find('#show-convict-fulfil-button').click }

      appointment.reload
      expect(appointment.state).to eq('fulfiled')
    end

    describe "if convict didn't came to appointment" do
      it 'change appointment state and sends sms', js: true do
        convict = create :convict, first_name: 'babar', last_name: 'bobor'
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

        apt_type = create :appointment_type, :with_notification_types
        slot = create :slot, date: Date.today, appointment_type: apt_type
        appointment = create :appointment, convict: convict, slot: slot

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
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
        apt_type = create(:appointment_type, :with_notification_types)
        slot = create :slot, date: Date.today, appointment_type: apt_type
        appointment = create :appointment, convict: convict, slot: slot

        appointment.book

        visit convict_path(convict)

        within first('.appointment-fulfilment-container') { click_button 'Non' }
        within("#missed-appointment-modal-#{appointment.id}") { click_button 'Non' }

        appointment.reload
        expect(appointment.state).to eq('no_show')
        expect(SmsDeliveryJob).not_to have_been_enqueued.with(appointment.no_show_notif)
      end

      it 'can be excused' do
        convict = create :convict
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
        apt_type = create :appointment_type, :with_notification_types
        slot = create :slot, date: Date.today, appointment_type: apt_type
        appointment = create :appointment, convict: convict, slot: slot

        appointment.book

        visit convict_path(convict)

        within first('.appointment-fulfilment-container') { click_button 'Excusé(e)' }

        appointment.reload
        expect(appointment.state).to eq('excused')
      end
    end
  end

  describe 'replanification' do
    it 're-schedules an appointment to a later date' do
      convict = create :convict
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
      apt_type = create(:appointment_type, :with_notification_types, name: "Sortie d'audience SPIP")
      slot1 = create :slot, appointment_type: apt_type
      appointment = create(:appointment, convict: convict, slot: slot1)

      appointment.book
      slot2 = create :slot, agenda: appointment.slot.agenda,
                            appointment_type: apt_type,
                            date: Date.today.next_occurring(:wednesday),
                            starting_time: '16h'

      visit appointment_path(appointment)
      click_button 'Replanifier'

      expect(page).to have_content 'Replanifier un rendez-vous'

      choose '16:00'
      click_button 'Enregistrer'

      appointment.reload
      expect(appointment.state).to eq 'canceled'
      expect(appointment.reminder_notif.state).to eq 'canceled'
      expect(appointment.cancelation_notif.state).to eq 'created'
      expect(appointment.history_items).to eq []

      new_appointment = Appointment.find_by(slot: slot2)

      expect(new_appointment.state).to eq 'booked'
      expect(new_appointment.history_items.count).to eq 4
      expect(new_appointment.reschedule_notif.state).to eq 'sent'
    end

    it 'works for an appointment type without pre defined slots' do
      convict = create :convict
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
      apt_type = create(:appointment_type, :with_notification_types, name: 'RDV de suivi SPIP')
      slot = create :slot, appointment_type: apt_type
      appointment = create(:appointment, convict: convict, slot: slot)

      appointment.book

      visit appointment_path(appointment)
      click_button 'Replanifier'

      expect(page).to have_content 'Replanifier un rendez-vous'

      fill_in 'appointment_slot_attributes_date', with: (Date.today.next_occurring(:wednesday)).strftime('%Y-%m-%d')

      within first('.form-time-select-fields') do
        select '15', from: 'appointment_slot_attributes_starting_time_4i'
        select '00', from: 'appointment_slot_attributes_starting_time_5i'
      end

      click_button 'Enregistrer'

      appointment.reload
      expect(appointment.state).to eq 'canceled'
      expect(appointment.reminder_notif.state).to eq 'canceled'
      expect(appointment.cancelation_notif.state).to eq 'created'
      expect(appointment.history_items).to eq []

      slot2 = Slot.find_by(date: Date.today.next_occurring(:wednesday))
      new_appointment = Appointment.find_by(slot: slot2)

      expect(new_appointment.state).to eq 'booked'
      expect(new_appointment.history_items.count).to eq 4
      expect(new_appointment.reschedule_notif.state).to eq 'sent'
    end
  end
end
