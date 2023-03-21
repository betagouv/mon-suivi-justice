require 'rails_helper'

RSpec.feature 'Appointments', type: :feature do
  before do
    # @user = create_admin_user_and_login
    # TODO : we should not have to return Place.all. The factory should add places to the user's organization
    # allow(Place).to receive(:in_departments).and_return(Place.all)
    # allow(Place).to receive(:in_dep_spips).and_return(Place.all)
  end

  describe 'index', logged_in_as: 'cpip' do
    before do
      place = create :place, organization: @user.organization
      @agenda = create :agenda, place: place

      apt_type = create(:appointment_type, :with_notification_types, name: "RDV de suivi SPIP")


      @slot1 = create(:slot, :without_validations, agenda: @agenda,
                                                   date: Date.civil(2025, 4, 14),
                                                   appointment_type: apt_type,
                                                   starting_time: new_time_for(13, 0))
      slot2 = create(:slot, agenda: @agenda,
                            date: Date.civil(2025, 4, 16),
                            starting_time: new_time_for(15, 30))

      slot3 = create(:slot, agenda: @agenda,
                            date: Date.today,
                            starting_time: new_time_for(14, 30))

      convict = create(:convict, organizations: [@user.organization])

      @appointment1 = create(:appointment, :with_notifications, convict: convict, slot: @slot1)
      create(:appointment, convict: convict, slot: slot2)
      create(:appointment, convict: convict, slot: slot3)
    end

    it 'display all appointments' do
      visit appointments_path

      expect(page).to have_content(Date.civil(2025, 4, 14))
      expect(page).to have_content('13:00')
      expect(page).to have_content(Date.civil(2025, 4, 16))
      expect(page).to have_content('15:30')
      expect(page).to have_content(Date.today)
      expect(page).to have_content('14:30')
    end

    it 'can display today\'s appointments using a query string' do
      visit appointments_path({ q: { slot_date_eq: Date.today.to_s } })

      expect(page).to have_content(Date.today)
      expect(page).to have_content('14:30')
    end

    it 'allows to filter appointments', js: true do
      visit appointments_path

      fill_in 'index-appointment-date-filter', with: Date.civil(2025, 4, 16)

      page.execute_script("document.getElementById('index-header-filters-form').submit()")

      expect(page).to have_content(Date.civil(2025, 4, 16))
      expect(page).not_to have_content(Date.civil(2025, 4, 14))
    end

    it "doesn't show canceled appointments" do
      convict = create(:convict, last_name: 'Gomez', organizations: [@user.organization])

      apt_type = create(:appointment_type, :with_notification_types, name: "Sortie d'audience SPIP")
      slot = create(:slot, date: Date.civil(2025, 4, 14),
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
      @slot1.update_attribute(:date, Date.today.prev_occurring(:monday))
      @appointment1.book

      visit appointments_path

      within first('.index-card-state-container') do
        click_button 'Honoré'
      end
      
      @appointment1.reload
      expect(@appointment1.state).to eq('fulfiled')
    end
  end

  describe 'creation', js: true, logged_in_as: 'cpip' do
    context 'appointment_type with predefined slots' do
      before do
        @convict = create(:convict, first_name: 'Joe', last_name: 'Dalton', organizations: [@user.organization])

        @appointment_type = create :appointment_type, :with_notification_types, name: "RDV de suivi SPIP"
        place = create :place, name: 'KFC de Chatelet', appointment_types: [@appointment_type],
                               organization: @user.organization
        @agenda = create :agenda, place: place, name: 'Agenda de Josiane'
        create :agenda, place: place, name: 'Agenda de Michel'

        @slot = create :slot, :without_validations, agenda: @agenda,
                                                    appointment_type: @appointment_type,
                                                    date: Date.civil(2025, 4, 14),
                                                    starting_time: new_time_for(16, 0)
      end

      it 'create an appointment with a convocation sms' do
        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'DALTON Joe').click
        select "RDV de suivi SPIP", from: :appointment_appointment_type_id
        select 'KFC de Chatelet', from: 'Lieu'
        select 'Agenda de Josiane', from: 'Agenda'
        fill_in "appointment_slot_date", with:  Date.today.strftime('%Y-%m-%d')
        select '16', from: 'appointment_slot_starting_time_4i'
        select '00', from: 'appointment_slot_starting_time_5i'

        expect(page).to have_button('Enregistrer')

        click_button 'Enregistrer'
        
        expect { click_button 'Oui' }.to change { Appointment.count }.by(1).and change { Notification.count }.by(5)

        expect(SmsDeliveryJob).to have_been_enqueued.once.with(
          Notification.find_by(role: :summon, appointment: Appointment.last).id
        )

        expect(SmsDeliveryJob).to have_been_enqueued.once.with(
          Notification.find_by(role: :reminder, appointment: Appointment.last).id
        )

        appointment = Appointment.last
        expect(appointment.inviter_user_id).to eq(@user.id)
      end

      it 'create an appointment without a convocation sms' do
        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'DALTON Joe').click
        select "Sortie d'audience SAP", from: :appointment_appointment_type_id
        select 'KFC de Chatelet', from: 'Lieu'
        select 'Agenda de Josiane', from: 'Agenda'
        choose '16:00'

        expect(page).to have_button('Enregistrer')

        click_button 'Enregistrer'

        expect { click_button 'Non' }.to change { Appointment.count }.by(1).and change { Notification.count }.by(5)

        expect(SmsDeliveryJob).to have_been_enqueued.once.with(
          Notification.find_by(role: :reminder, appointment: Appointment.find_by(slot: @slot)).id
        )
      end

      it 'allows an agent to create appointment only for his service places & slots' do
        department = create :department, number: '09', name: 'Ariège'
        logout_current_user
        organization = create :organization, organization_type: 'tj'
        create :areas_organizations_mapping, organization: organization, area: department
        agent = create :user, role: :jap, organization: organization
        login_user agent

        convict = create :convict, first_name: 'Jack', last_name: 'Dalton'
        create :areas_convicts_mapping, convict: convict, area: department

        place_in = create :place, organization: organization, name: 'place_in_name',
                                  appointment_types: [@appointment_type]
        agenda_in = create :agenda, place: place_in, name: 'agenda_in_name'
        create :agenda, place: place_in, name: 'other_agenda_in_name'

        organization_out = create :organization, organization_type: 'tj'
        place_out = create :place, organization: organization_out, name: 'place_out_name',
                                   appointment_types: [@appointment_type]
        agenda_out = create :agenda, place: place_out, name: 'agenda_out_name'

        create :slot, agenda: agenda_in, appointment_type: @appointment_type, date: Date.civil(2025, 4, 18),
                      starting_time: new_time_for(14, 0)
        create :slot, agenda: agenda_out, appointment_type: @appointment_type, date: Date.civil(2025, 4, 18),
                      starting_time: new_time_for(16, 0)

        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'DALTON Jack').click
        select "Sortie d'audience SAP", from: :appointment_appointment_type_id
        expect(page).not_to have_select('Lieu', options: ['', 'place_in_name', 'place_out_name'])
        expect(page).to have_select('Lieu', options: ['', 'place_in_name'])
        select 'place_in_name', from: 'Lieu'
        expect(page).not_to have_select('Agenda',
                                        options: ['', 'agenda_in_name', 'agenda_out_name', 'other_agenda_in_name'])
        expect(page).to have_select('Agenda',
                                    options: ['', 'Tous les agendas', 'agenda_in_name', 'other_agenda_in_name'])
        select 'agenda_in_name', from: 'Agenda'
        choose '14:00'
        expect(page).to have_button('Enregistrer')

        click_button 'Enregistrer'

        expect { click_button 'Oui' }.to change { Appointment.count }.by(1)
                                     .and change { Notification.count }.by(5)
      end

      it 'shows only relevant places for an appointment type' do
        apt_type2 = create(:appointment_type, name: 'RDV de test SAP')

        create(:place, name: 'Quick de Montreuil', appointment_types: [apt_type2])
        create(:place, name: 'McDo de Barbès', appointment_types: [@appointment_type])

        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'DALTON Joe').click

        select 'RDV de test SAP', from: :appointment_appointment_type_id

        expect(page).not_to have_select('Lieu', options: ['', 'McDo de Barbès', 'Quick de Montreuil'])
        expect(page).to have_select('Lieu', options: ['', 'Quick de Montreuil'])
      end

      it 'allows to see all agendas at once for some appointment_types' do
        appointment_type = create :appointment_type, :with_notification_types, name: "Sortie d'audience SPIP"
        place1 = create :place, name: 'SPIP 93', appointment_types: [appointment_type],
                                organization: @user.organization
        agenda = create :agenda, place: place1, name: 'Cabinet 28'
        create :agenda, place: place1, name: 'Cabinet 32'
        create :slot, agenda: agenda,
                      appointment_type: appointment_type,
                      date: Date.civil(2025, 4, 14),
                      starting_time: new_time_for(17, 0)

        place2 = create :place, name: 'SPIP 73', appointment_types: [appointment_type]
        agenda2 = create :agenda, place: place2, name: 'Cabinet 74'
        create :slot, agenda: agenda2,
                      appointment_type: appointment_type,
                      date: Date.civil(2025, 4, 14),
                      starting_time: new_time_for(19, 0)

        agenda3 = create :agenda, place: place1, name: 'Cabinet 22'
        create :slot, agenda: agenda3,
                      appointment_type: appointment_type,
                      date: Date.civil(2025, 4, 14),
                      starting_time: new_time_for(11, 0)

        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'DALTON Joe').click
        select "Sortie d'audience SPIP", from: :appointment_appointment_type_id
        select 'SPIP 93', from: 'Lieu'
        select 'Tous les agendas', from: 'Agenda'
        choose '17:00 - Cabinet 28'

        expect(page).to have_content('11:00 - Cabinet 22')
        expect(page).not_to have_content('19:00 - Cabinet 74')

        click_button 'Enregistrer'

        expect { click_button 'Oui' }.to change { Appointment.count }.by(1).and change { Notification.count }.by(5)
      end

      it 'allows an agent to setup a meeting in another department' do
        department = create :department, number: '09', name: 'Ariège'
        organization = create :organization, name: 'TJ Foix', organization_type: 'tj'
        create :areas_organizations_mapping, organization: organization, area: department

        place_ariege = create :place, organization: organization, name: 'SAP TJ Foix',
                                      appointment_types: [@appointment_type]
        agenda_ariege = create :agenda, place: place_ariege, name: 'agenda SAP Foix'
        create :agenda, place: place_ariege, name: 'agenda 2 SAP Foix'

        create :slot, agenda: agenda_ariege, appointment_type: @appointment_type, date: Date.civil(2025, 4, 18),
                      starting_time: new_time_for(17, 0)

        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'DALTON Joe').click
        select "Sortie d'audience SAP", from: :appointment_appointment_type_id

        expect(page).to have_content('KFC de Chatelet')

        click_link 'Prendre RDV hors du ressort'
        select '09 - Ariège', from: 'appointment-form-department-select'
        select 'SAP TJ Foix', from: 'Lieu'
        select 'agenda SAP Foix', from: 'Agenda'

        choose '17:00'

        click_button 'Enregistrer'

        expect { click_button 'Non' }.to change { Appointment.count }.by(1)
                                     .and change { Notification.count }.by(5)
      end
    end

    context 'appointment_type without predefined slots' do
      before do
        convict = create :convict, first_name: 'Momo', last_name: 'La Fouine'
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
        appointment_type = create :appointment_type, :with_notification_types, name: 'RDV de suivi JAP'
        place = create :place, name: 'McDo des Halles', appointment_types: [appointment_type],
                               organization: @user.organization
        create :agenda, place: place, name: 'Agenda de Jean-Louis'
        create :agenda, place: place, name: 'Agenda de Mireille'
      end

      it 'creates an appointment' do
        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'LA FOUINE Momo').click

        select 'RDV de suivi JAP', from: :appointment_appointment_type_id
        select 'McDo des Halles', from: 'Lieu'
        select 'Agenda de Jean-Louis', from: 'Agenda'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        click_button 'Enregistrer'

        expect { click_button 'Oui' }.to change { Appointment.count }.by(1)
                                    .and change { Slot.count }.by(1)
                                    .and change { Notification.count }.by(5)
      end

      it 'allows to book appointment on weekends for some appointment_types' do
        appointment_type2 = create :appointment_type, :with_notification_types, name: 'Placement TIG/TNR'
        place2 = create :place, name: 'Foirfouille de Melun', appointment_types: [appointment_type2],
                                organization: @user.organization
        create :agenda, place: place2, name: 'Agenda de Martin'

        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'LA FOUINE Momo').click

        select 'Placement TIG/TNR', from: :appointment_appointment_type_id
        select 'Foirfouille de Melun', from: 'Lieu'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 19).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        click_button 'Enregistrer'

        expect { click_button 'Oui' }.to change { Appointment.count }.by(1)
                                    .and change { Slot.count }.by(1)
                                    .and change { Notification.count }.by(5)
      end

      it "doesn't propose convocation SMS if the convict has no phone" do
        convict2 = create :convict, first_name: 'Momo', last_name: 'Le renard', phone: nil, no_phone: true
        create :areas_convicts_mapping, convict: convict2, area: @user.organization.departments.first

        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'LE RENARD Momo').click

        select 'RDV de suivi JAP', from: :appointment_appointment_type_id
        select 'McDo des Halles', from: 'Lieu'
        select 'Agenda de Jean-Louis', from: 'Agenda'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        expect { click_button 'Enregistrer' }.to change { Appointment.count }.by(1)
                                             .and change { Slot.count }.by(1)
                                             .and change { Notification.count }.by(5)
      end

      it 'does not create appointment if the selected date is a weekend' do
        visit new_appointment_path

        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'LA FOUINE Momo').click

        select 'RDV de suivi JAP', from: :appointment_appointment_type_id
        select 'McDo des Halles', from: 'Lieu'
        select 'Agenda de Jean-Louis', from: 'Agenda'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 19).strftime('%Y-%m-%d')

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

      it 'links the PPSMJ to the CPIP if wanted' do
        @user = create_cpip_user_and_login
        convict = create(:convict, first_name: 'JP', last_name: 'Cherty')
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
        appointment_type = create :appointment_type, :with_notification_types, name: '1er RDV SPIP'
        place = create :place, name: 'KFC de Chatelet', appointment_types: [appointment_type],
                               organization: @user.organization
        create :agenda, place: place, name: 'Agenda de Josiane'
        create :agenda, place: place, name: 'Agenda de Michel'

        visit new_appointment_path
        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'CHERTY Jp').click
        choose('appointment[user_is_cpip]', option: '1')
        select '1er RDV SPIP', from: :appointment_appointment_type_id
        select 'KFC de Chatelet', from: 'Lieu'
        select 'Agenda de Josiane', from: 'Agenda'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        click_button 'Enregistrer'
        click_button 'Non'
        expect(Appointment.last.convict.cpip).to eq(@user)
      end

      it 'does not link the PPSMJ to the CPIP if not wanted' do
        @user = create_cpip_user_and_login
        convict = create(:convict, first_name: 'JP', last_name: 'Cherty')
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
        appointment_type = create :appointment_type, :with_notification_types, name: '1er RDV SPIP'
        place = create :place, name: 'KFC de Chatelet', appointment_types: [appointment_type],
                               organization: @user.organization
        create :agenda, place: place, name: 'Agenda de Josiane'
        create :agenda, place: place, name: 'Agenda de Michel'

        visit new_appointment_path
        first('.select2-container', minimum: 1).click
        find('li.select2-results__option', text: 'CHERTY Jp').click
        choose('appointment[user_is_cpip]', option: '0')
        select '1er RDV SPIP', from: :appointment_appointment_type_id
        select 'KFC de Chatelet', from: 'Lieu'
        select 'Agenda de Josiane', from: 'Agenda'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        click_button 'Enregistrer'
        click_button 'Non'

        expect(Appointment.last.convict.cpip).to be_nil
      end
    end
  end

  describe 'show' do
    it 'displays appointment data' do
      appointment_type = create :appointment_type, name: "Sortie d'audience SAP"
      slot = create(:slot, :without_validations, appointment_type: appointment_type,
                                                 date: Date.civil(2025, 4, 16),
                                                 starting_time: new_time_for(17, 0))
      convict = create(:convict, first_name: 'Monique', last_name: 'Lassalle')
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      appointment = create(:appointment, :with_notifications, slot: slot, convict: convict, prosecutor_number: '12345')

      visit appointment_path(appointment)

      expect(page).to have_content(Date.civil(2025, 4, 16))
      expect(page).to have_content('17:00')
      expect(page).to have_content('Monique')
      expect(page).to have_content('LASSALLE')
      expect(page).to have_content('12345')
    end

    it 'allows to change state of appointment' do
      appointment_type = create :appointment_type, name: "Sortie d'audience SAP"

      slot = create(:slot, :without_validations, appointment_type: appointment_type,
                                                 date: Date.today - 1.days,
                                                 starting_time: Time.now)

      convict = create(:convict, first_name: 'Jean', last_name: 'Lassoulle')
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
      appointment = build(:appointment, :with_notifications, convict: convict, state: :booked, slot: slot)

      appointment.save validate: false

      create(:notification, appointment: appointment,
                            role: 'no_show',
                            content: "Sérieusement, vous n'êtes pas venu ?")

      appointment.fulfil

      visit appointment_path(appointment)

      expect(page).to have_content('Honoré')
      expect(page).to have_content("s'est bien présenté(e) à son rendez-vous")

      within first('.show-appointment-state-container') do
        click_link 'Modifier'
      end

      appointment.reload
      expect(appointment.state).to eq('booked')

      expect(page).to have_content('Planifié')
      expect(page).not_to have_content('Modifier')
      expect(page).not_to have_content("s'est bien présenté(e) à son rendez-vous")
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
    before do
      place = create :place, organization: @user.organization
      @agenda = create :agenda, place: place
    end
    it 'controls are only displayed for passed appointments' do
      convict = create :convict
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      apt_type = create :appointment_type, :with_notification_types
      slot = create :slot, date: Date.civil(2025, 4, 14), starting_time: Time.now - 1.minutes,
                           appointment_type: apt_type, agenda: @agenda
      appointment = create :appointment, convict: convict, slot: slot

      appointment.book

      visit convict_path(convict)

      expect(page).not_to have_selector '.appointment-fulfilment-container'
    end

    it 'works if convict came to appointment' do
      convict = create :convict
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
      apt_type = create :appointment_type, :with_notification_types
      slot = create :slot, :without_validations, date: Date.today, starting_time: Time.now - 1.minutes,
                                                 appointment_type: apt_type, agenda: @agenda
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
      slot = create :slot, :without_validations, date: Date.today, appointment_type: apt_type, agenda: @agenda
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
        slot = create :slot, :without_validations, date: Date.today, starting_time: Time.now - 1.minutes,
                                                   appointment_type: apt_type, agenda: @agenda
        appointment = create :appointment, convict: convict, slot: slot

        appointment.book

        visit convict_path(convict)

        within first('.appointment-fulfilment-container') { click_button 'Non' }
        within("#missed-appointment-modal-#{appointment.id}") { click_button 'Oui' }

        appointment.reload
        expect(appointment.state).to eq('no_show')
        expect(SmsDeliveryJob).to have_been_enqueued.once.with(appointment.no_show_notif.id)
      end

      it "change appointment state and don't send sms", js: true do
        convict = create(:convict, first_name: 'babar', last_name: 'bobor')
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
        apt_type = create(:appointment_type, :with_notification_types)
        slot = create :slot, :without_validations, date: Date.today, starting_time: Time.now - 1.minutes,
                                                   appointment_type: apt_type, agenda: @agenda
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
        slot = create :slot, :without_validations, date: Date.today, starting_time: Time.now - 1.minutes,
                                                   appointment_type: apt_type, agenda: @agenda
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
                            date: Date.civil(2025, 4, 16),
                            starting_time: new_time_for(16, 0)

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

      fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 16).strftime('%Y-%m-%d')

      within first('.form-time-select-fields') do
        select '15', from: 'appointment_slot_starting_time_4i'
        select '00', from: 'appointment_slot_starting_time_5i'
      end

      click_button 'Enregistrer'

      appointment.reload
      expect(appointment.state).to eq 'canceled'
      expect(appointment.reminder_notif.state).to eq 'canceled'
      expect(appointment.cancelation_notif.state).to eq 'created'
      expect(appointment.history_items).to eq []

      slot2 = Slot.find_by(date: Date.civil(2025, 4, 16))
      new_appointment = Appointment.find_by(slot: slot2)

      expect(new_appointment.localized_time.hour).to eq 15
      expect(new_appointment.state).to eq 'booked'
      expect(new_appointment.history_items.count).to eq 4
      expect(new_appointment.reschedule_notif.state).to eq 'sent'
    end
  end
end
