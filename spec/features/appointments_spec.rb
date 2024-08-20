require 'rails_helper'

RSpec.feature 'Appointments', type: :feature do
  describe 'index', logged_in_as: 'cpip' do
    before do
      place = create :place, organization: @user.organization
      @agenda = create(:agenda, place:)

      apt_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                     name: 'Convocation de suivi SPIP')

      @slot1 = create(:slot, :without_validations, agenda: @agenda,
                                                   date: Date.civil(2025, 4, 14),
                                                   appointment_type: apt_type,
                                                   starting_time: new_time_for(13, 0))
      slot2 = create(:slot, agenda: @agenda,
                            date: Date.civil(2025, 4, 16),
                            starting_time: new_time_for(15, 30))

      slot3 = create(:slot, agenda: @agenda,
                            date: next_valid_day(date: Date.today),
                            starting_time: new_time_for(14, 30))

      convict = create(:convict, organizations: [@user.organization])

      @appointment1 = create(:appointment, :with_notifications,
                             convict:,
                             slot: @slot1,
                             creating_organization: @user.organization)
      create(:appointment, convict:, slot: slot2)
      create(:appointment, convict:, slot: slot3)
    end

    it 'display all appointments' do
      visit appointments_path

      expect(page).to have_content(Date.civil(2025, 4, 14).to_fs(:base_date_format))
      expect(page).to have_content('13:00')
      expect(page).to have_content(Date.civil(2025, 4, 16).to_fs(:base_date_format))
      expect(page).to have_content('15:30')
      expect(page).to have_content(next_valid_day(date: Date.today).to_fs(:base_date_format))
      expect(page).to have_content('14:30')
    end

    it 'allows to filter appointments', js: true do
      visit appointments_path

      fill_in 'index-appointment-date-filter', with: Date.civil(2025, 4, 16)

      page.execute_script("document.getElementById('index-header-filters-form').submit()")

      expect(page).to have_content(Date.civil(2025, 4, 16).to_fs(:base_date_format))
      expect(page).not_to have_content(Date.civil(2025, 4, 14).to_fs(:base_date_format))
    end

    it "doesn't show canceled appointments" do
      convict = create(:convict, last_name: 'Gomez', organizations: [@user.organization])

      apt_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                     name: "Sortie d'audience SPIP")
      slot = create(:slot, date: Date.civil(2025, 4, 14),
                           agenda: @agenda,
                           appointment_type: apt_type,
                           starting_time: new_time_for(14, 0))
      appointment = create(:appointment, :with_notifications, convict:, slot:)

      appointment.book
      appointment.cancel

      visit appointments_path
      expect(page).not_to have_content('GOMEZ')
    end

    it 'allows to indicate the state of appointments' do
      @slot1.update_attribute(:date, Date.today.prev_occurring(:monday))
      @appointment1.book

      visit appointments_path

      button_groups = all('.index-card-state-container')

      within(button_groups[2]) do
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

        @appointment_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                                name: 'Convocation de suivi SPIP'
        place = create :place, name: 'Test place', appointment_types: [@appointment_type],
                               organization: @user.organization
        @agenda = create :agenda, place:, name: 'Agenda de Josiane'
        create :agenda, place:, name: 'Agenda 2'

        @slot = create :slot, :without_validations, agenda: @agenda,
                                                    appointment_type: @appointment_type,
                                                    date: Date.civil(2025, 4, 14),
                                                    starting_time: new_time_for(16, 0)
      end

      it 'create an appointment with a convocation sms' do
        visit new_appointment_path({ convict_id: @convict.id })

        select 'Convocation de suivi SPIP', from: :appointment_appointment_type_id
        select 'Test place', from: 'Lieu'
        select 'Agenda de Josiane', from: 'Agenda'
        fill_in 'appointment_slot_date', with: next_valid_day(date: Date.today).strftime('%Y-%m-%d')
        select '16', from: 'appointment_slot_starting_time_4i'
        select '00', from: 'appointment_slot_starting_time_5i'

        page.find('label[for="send_sms_1"]').click
        expect(page).to have_button('Convoquer')

        expect { click_button 'Convoquer' }.to change { Appointment.count }
                                                                .by(1).and change { Notification.count }.by(5)

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
        visit new_appointment_path({ convict_id: @convict.id })

        select 'Convocation de suivi SPIP', from: :appointment_appointment_type_id
        select 'Test place', from: 'Lieu'
        select 'Agenda de Josiane', from: 'Agenda'
        fill_in 'appointment_slot_date', with: next_valid_day(date: Date.today).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '16', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        page.find('label[for="send_sms_0"]').click

        expect(page).to have_button('Convoquer')

        expect { click_button 'Convoquer' }.to change { Appointment.count }
                                                                  .by(1).and change { Notification.count }.by(5)

        expect(SmsDeliveryJob).to have_been_enqueued.once.with(
          Notification.find_by(role: :reminder, appointment: Appointment.last).id
        )

        expect(SmsDeliveryJob).to have_been_enqueued.at_most(0).with(
          Notification.find_by(role: :summon, appointment: Appointment.last).id
        )
      end

      it 'allows an agent to create appointment only for his service places & slots', logged_in_as: 'jap' do
        appointment_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                               name: "Sortie d'audience SAP"
        appointment_type_spip = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                                    name: "Sortie d'audience SPIP"

        convict = create :convict, first_name: 'Jack', last_name: 'Dalton', organizations: [@user.organization]

        place_in = create :place, organization: @user.organization, name: 'place_in_name',
                                  appointment_types: [appointment_type]
        agenda_in = create :agenda, place: place_in, name: 'agenda_in_name'
        create :agenda, place: place_in, name: 'other_agenda_in_name'

        organization_out = create :organization, organization_type: 'spip'
        place_out = create :place, organization: organization_out, name: 'place_out_name',
                                   appointment_types: [appointment_type]
        agenda_out = create :agenda, place: place_out, name: 'agenda_out_name'

        create :slot, agenda: agenda_in, appointment_type:, date: Date.civil(2025, 4, 18),
                      starting_time: new_time_for(14, 0)
        create :slot, agenda: agenda_out, appointment_type: appointment_type_spip, date: Date.civil(2025, 4, 18),
                      starting_time: new_time_for(16, 0)

        visit new_appointment_path({ convict_id: convict })

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

        page.find('label[for="send_sms_1"]').click

        expect(page).to have_button('Convoquer')

        expect { click_button 'Convoquer' }.to change { Appointment.count }.by(1)
                                     .and change { Notification.count }.by(5)
      end

      it 'allows to see all agendas at once for some appointment_types' do
        appointment_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                               name: "Sortie d'audience SPIP"
        place1 = create :place, name: 'SPIP 93', appointment_types: [appointment_type],
                                organization: @user.organization
        agenda = create :agenda, place: place1, name: 'Cabinet 28'
        create :agenda, place: place1, name: 'Cabinet 32'
        create :slot, agenda:,
                      appointment_type:,
                      date: Date.civil(2025, 4, 14),
                      starting_time: new_time_for(17, 0)

        place2 = create :place, name: 'SPIP 73', appointment_types: [appointment_type]
        agenda2 = create :agenda, place: place2, name: 'Cabinet 74'
        create :slot, agenda: agenda2,
                      appointment_type:,
                      date: Date.civil(2025, 4, 14),
                      starting_time: new_time_for(19, 0)

        agenda3 = create :agenda, place: place1, name: 'Cabinet 22'
        create :slot, agenda: agenda3,
                      appointment_type:,
                      date: Date.civil(2025, 4, 14),
                      starting_time: new_time_for(11, 0)

        visit new_appointment_path({ convict_id: @convict.id })

        select "Sortie d'audience SPIP", from: :appointment_appointment_type_id
        select 'SPIP 93', from: 'Lieu'
        select 'Tous les agendas', from: 'Agenda'
        choose '17:00 - Cabinet 28'

        expect(page).to have_content('11:00 - Cabinet 22')
        expect(page).not_to have_content('19:00 - Cabinet 74')

        page.find('label[for="send_sms_1"]').click

        expect { click_button 'Convoquer' }.to change { Appointment.count }.by(1)
                                                                .and change { Notification.count }.by(5)
      end
      context 'Inter-Ressort' do
        it 'allows an agent to setup an appointment in another service',
           logged_in_as: 'bex_interressort' do
          organization = create :organization, name: 'TJ Foix', organization_type: 'tj'
          appointment_type = create :appointment_type, :with_notification_types, organization:,
                                                                                 name: "Sortie d'audience SAP"
          create :place, name: 'Test place', appointment_types: [appointment_type],
                         organization: @user.organization

          @convict.organizations << organization

          place_ariege = create :place, organization:, name: 'SAP TJ Foix',
                                        appointment_types: [appointment_type]
          agenda_ariege = create :agenda, place: place_ariege, name: 'agenda SAP Foix'
          create :agenda, place: place_ariege, name: 'agenda 2 SAP Foix'

          create :slot, agenda: agenda_ariege, appointment_type:, date: Date.civil(2025, 4, 18),
                        starting_time: new_time_for(17, 0)

          visit new_appointment_path({ convict_id: @convict.id })

          select "Sortie d'audience SAP", from: :appointment_appointment_type_id

          expect(page).to have_content('Test place')

          select 'SAP TJ Foix', from: 'Lieu'
          select 'agenda SAP Foix', from: 'Agenda'

          choose '17:00'

          page.find('label[for="send_sms_1"]').click

          expect { click_button 'Convoquer' }.to change { Appointment.count }.by(1)
                                       .and change { Notification.count }.by(5)
        end
      end
    end

    context 'appointment_type without predefined slots', logged_in_as: 'cpip' do
      before do
        @convict = create(:convict, first_name: 'Momo', last_name: 'La Fouine', organizations: [@user.organization])

        appointment_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                               name: 'Convocation de suivi SPIP'
        place = create :place, name: 'Lieu test', appointment_types: [appointment_type],
                               organization: @user.organization
        create :agenda, place:, name: 'Agenda de Jean-Louis'
        create :agenda, place:, name: 'Agenda de Mireille'
      end

      it 'creates an appointment' do
        visit new_appointment_path({ convict_id: @convict.id })

        select 'Convocation de suivi SPIP', from: :appointment_appointment_type_id
        select 'Lieu test', from: 'Lieu'
        select 'Agenda de Jean-Louis', from: 'Agenda'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        page.find('label[for="send_sms_1"]').click

        expect { click_button 'Convoquer' }.to change { Appointment.count }.by(1)
                                    .and change { Slot.count }.by(1)
                                    .and change { Notification.count }.by(5)
      end

      it 'allows to book appointment on weekends for some appointment_types' do
        appointment_type2 = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                                name: 'Placement TIG/TNR'
        place2 = create :place, name: 'Foirfouille de Melun', appointment_types: [appointment_type2],
                                organization: @user.organization
        create :agenda, place: place2, name: 'Agenda de Martin'

        visit new_appointment_path({ convict_id: @convict.id })

        select 'Placement TIG/TNR', from: :appointment_appointment_type_id
        select 'Foirfouille de Melun', from: 'Lieu'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 19).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        page.find('label[for="send_sms_1"]').click

        expect { click_button 'Convoquer' }.to change { Appointment.count }.by(1)
                                    .and change { Slot.count }.by(1)
                                    .and change { Notification.count }.by(5)
      end

      it "doesn't propose convocation SMS if the convict has no phone" do
        convict = create :convict, first_name: 'Momo', last_name: 'Le renard', phone: nil, no_phone: true,
                                   organizations: [@user.organization]

        visit new_appointment_path({ convict_id: convict.id })

        select 'Convocation de suivi SPIP', from: :appointment_appointment_type_id
        select 'Lieu test', from: 'Lieu'
        select 'Agenda de Jean-Louis', from: 'Agenda'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        expect(page).not_to have_content('Prévenir immédiatement par SMS et envoyer un rappel avant la convocation.')

        expect { click_button 'Convoquer' }.to change { Appointment.count }.by(1)
                                             .and change { Slot.count }.by(1)
                                             .and change { Notification.count }.by(5)
      end

      it 'does not create appointment if the selected date is a weekend' do
        visit new_appointment_path({ convict_id: @convict.id })

        select 'Convocation de suivi SPIP', from: :appointment_appointment_type_id
        select 'Lieu test', from: 'Lieu'
        select 'Agenda de Jean-Louis', from: 'Agenda'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 19).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        page.find('label[for="send_sms_0"]').click

        expect { click_button 'Convoquer' }.to change { Appointment.count }.by(0)
                                    .and change { Slot.count }.by(0)
                                    .and change { Notification.count }.by(0)

        expect(page).to have_content("Le jour sélectionné n'est pas un jour ouvrable")
      end

      it 'links the Probationnaire to the CPIP if wanted' do
        convict = create(:convict, first_name: 'JP', last_name: 'Cherty', organizations: [@user.organization])
        appointment_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                               name: '1ère convocation de suivi SPIP'
        place = create :place, name: 'Test place', appointment_types: [appointment_type],
                               organization: @user.organization
        create :agenda, place:, name: 'Agenda de Josiane'
        create :agenda, place:, name: 'Agenda 2'

        visit new_appointment_path({ convict_id: convict.id })

        choose('appointment[user_is_cpip]', option: '1')
        select '1ère convocation de suivi SPIP', from: :appointment_appointment_type_id
        select 'Test place', from: 'Lieu'
        select 'Agenda de Josiane', from: 'Agenda'

        fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

        within first('.form-time-select-fields') do
          select '15', from: 'appointment_slot_starting_time_4i'
          select '00', from: 'appointment_slot_starting_time_5i'
        end

        page.find('label[for="send_sms_0"]').click

        click_button 'Convoquer'
        expect(Appointment.last.convict.cpip).to eq(@user)
      end
    end
  end

  describe 'show', logged_in_as: 'cpip' do
    it 'displays appointment data' do
      place = create :place, organization: @user.organization
      agenda = create(:agenda, place:)
      appointment_type = create :appointment_type, name: "Sortie d'audience SPIP"
      slot = create(:slot, :without_validations, appointment_type:,
                                                 agenda:,
                                                 date: Date.civil(2025, 4, 16).to_fs,
                                                 starting_time: new_time_for(17, 0))

      convict = create(:convict, first_name: 'Monique', last_name: 'Lassalle', organizations: [@user.organization])
      appointment = create(:appointment, :with_notifications, slot:, convict:, prosecutor_number: '12345')

      visit appointment_path(appointment)

      expect(page).to have_content(Date.civil(2025, 4, 16).to_fs)
      expect(page).to have_content('17:00')
      expect(page).to have_content('Monique')
      expect(page).to have_content('LASSALLE')
      expect(page).to have_content('12345')
    end

    it 'allows to change state of appointment' do
      apt_type = create :appointment_type, name: "Sortie d'audience SPIP"

      place = create :place, name: 'Test place', appointment_types: [apt_type],
                             organization: @user.organization
      create :agenda, place:, name: 'Agenda de test'

      slot = create(:slot, :without_validations, appointment_type: apt_type,
                                                 date: Date.today - 1.days,
                                                 starting_time: Time.now,
                                                 agenda: @user.organization.agendas.first)

      convict = create(:convict, first_name: 'Jean', last_name: 'Lassoulle', organizations: [@user.organization])
      appointment = build(:appointment, :with_notifications, convict:, state: :booked, slot:)

      appointment.save validate: false

      create(:notification, appointment:,
                            role: 'no_show',
                            content: "Sérieusement, vous n'êtes pas venu ?")

      appointment.fulfil

      visit appointment_path(appointment)

      expect(page).to have_content('Honoré')
      expect(page).to have_content("s'est bien presenté à sa convocation")

      within first('.show-appointment-state-container') do
        click_link 'Modifier'
      end

      appointment.reload
      expect(appointment.state).to eq('booked')

      expect(page).to have_content('Planifié')
      expect(page).not_to have_content('Modifier')
      expect(page).not_to have_content("s'est bien presenté à sa convocation")
    end
  end

  describe 'cancelation', logged_in_as: 'cpip' do
    before do
      @convict = create(:convict, organizations: [@user.organization])
    end

    it 'change state and cancel notifications and send sms' do
      apt_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                     name: 'Convocation de suivi SPIP')
      place = create :place, name: 'Test place', appointment_types: [apt_type],
                             organization: @user.organization
      create :agenda, place:, name: 'Agenda de test'
      slot = create :slot, appointment_type: apt_type, agenda: @user.organization.agendas.first

      appointment = create(:appointment, convict: @convict, slot:)

      appointment.book
      expect(appointment.state).to eq('booked')
      expect(appointment.notifications.count).to eq(5)
      expect(appointment.reminder_notif.state).to eq('programmed')
      expect(appointment.cancelation_notif.state).to eq('created')

      visit appointment_path(appointment)
      click_button 'Annuler'
      click_button 'Annuler et prévenir le probationnaire'
      appointment.reload
      expect(appointment.state).to eq('canceled')
      expect(appointment.reminder_notif.state).to eq('canceled')
      # cancellation notification is sent
      expect(appointment.cancelation_notif.state).to eq('programmed')

      expect(page).to have_current_path(appointment_path(appointment))
    end

    it 'change state and cancel notifications without sms' do
      apt_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                     name: 'Convocation de suivi SPIP')
      place = create :place, name: 'Test place', appointment_types: [apt_type],
                             organization: @user.organization
      create :agenda, place:, name: 'Agenda de test'
      slot = create :slot, appointment_type: apt_type, agenda: @user.organization.agendas.first

      appointment = create(:appointment, convict: @convict, slot:)

      appointment.book
      expect(appointment.state).to eq('booked')
      expect(appointment.notifications.count).to eq(5)
      expect(appointment.reminder_notif.state).to eq('programmed')
      expect(appointment.cancelation_notif.state).to eq('created')

      visit appointment_path(appointment)
      click_button 'Annuler'
      click_button 'Annuler sans prévenir le probationnaire'
      appointment.reload
      expect(appointment.state).to eq('canceled')
      expect(appointment.reminder_notif.state).to eq('canceled')

      # cancellation notification is not sent
      expect(appointment.cancelation_notif.state).to eq('created')

      expect(page).to have_current_path(appointment_path(appointment))
    end

    it 'cant cancel a not-booked appointment' do
      appointment = create :appointment, :with_notifications, convict: @convict
      visit appointment_path(appointment)
      expect(page).not_to have_button 'Annuler'
    end
  end

  describe 'fulfilment', logged_in_as: 'cpip' do
    before do
      place = create :place, organization: @user.organization
      @agenda = create :agenda, place:
    end
    it 'displays controls only for passed appointments' do
      convict = create(:convict, organizations: [@user.organization])

      apt_type = create :appointment_type, :with_notification_types, organization: @user.organization
      slot = create :slot, date: Date.civil(2025, 4, 14), starting_time: Time.now - 1.minutes,
                           appointment_type: apt_type, agenda: @agenda
      appointment = create(:appointment, convict:, slot:)

      appointment.book

      visit convict_path(convict)

      expect(page).not_to have_selector '.appointment-fulfilment-container'
    end

    it 'allows agents to mark appointments as fullfiled' do
      convict = create(:convict, organizations: [@user.organization])
      apt_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                     name: 'Convocation de suivi SPIP'
      slot = create :slot, :without_validations, date: Date.today, starting_time: Time.now - 1.minutes,
                                                 appointment_type: apt_type, agenda: @agenda
      appointment = create(:appointment, :skip_validate, convict:, slot:)

      appointment.book

      visit convict_path(convict)
      within first('.appointment-fulfilment-container') { find('#show-convict-fulfil-button').click }

      appointment.reload
      expect(appointment.state).to eq('fulfiled')
    end

    it 'is also available on appointment#show page' do
      convict = create(:convict, organizations: [@user.organization])
      apt_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                     name: 'Convocation de suivi SPIP'
      slot = create :slot, :without_validations, date: Date.yesterday, appointment_type: apt_type, agenda: @agenda
      appointment = create(:appointment, :skip_validate, convict:, slot:)

      appointment.book

      visit appointment_path(appointment)
      within first('.appointment-fulfilment-container') { find('#show-convict-fulfil-button').click }

      appointment.reload
      expect(appointment.state).to eq('fulfiled')
    end

    describe "if convict didn't came to appointment", logged_in_as: 'cpip' do
      it 'change appointment state and sends sms', js: true do
        convict = create(:convict, first_name: 'babar', last_name: 'bobor', organizations: [@user.organization])
        apt_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                       name: 'Convocation de suivi SPIP'
        slot = create :slot, :without_validations, date: Date.today, starting_time: Time.now - 1.minutes,
                                                   appointment_type: apt_type, agenda: @agenda
        appointment = create(:appointment, :skip_validate, convict:, slot:)

        appointment.book

        visit convict_path(convict)

        within first('.appointment-fulfilment-container') { first('.show-convict-miss-button').click }
        within("#missed-appointment-modal-#{appointment.id}") { all('.show-convict-fulfil-button').last.click }

        appointment.reload
        expect(appointment.state).to eq('no_show')
        expect(SmsDeliveryJob).to have_been_enqueued.once.with(appointment.no_show_notif.id)
      end

      it "change appointment state and don't send sms", js: true do
        convict = create(:convict, first_name: 'babar', last_name: 'bobor', organizations: [@user.organization])
        apt_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                       name: 'Convocation de suivi SPIP')
        slot = create :slot, :without_validations, date: Date.today, starting_time: Time.now - 1.minutes,
                                                   appointment_type: apt_type, agenda: @agenda
        appointment = create(:appointment, :skip_validate, convict:, slot:)

        appointment.book

        visit convict_path(convict)

        within first('.appointment-fulfilment-container') { first('.show-convict-miss-button').click }
        within("#missed-appointment-modal-#{appointment.id}") { all('.show-convict-miss-button').last.click }

        appointment.reload
        expect(appointment.state).to eq('no_show')
        expect(SmsDeliveryJob).not_to have_been_enqueued.with(appointment.no_show_notif)
      end

      it 'can be excused' do
        convict = create(:convict, organizations: [@user.organization])

        apt_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                       name: 'Convocation de suivi SPIP'
        slot = create :slot, :without_validations, date: Date.tomorrow, starting_time: Time.now - 1.minutes,
                                                   appointment_type: apt_type, agenda: @agenda
        appointment = create(:appointment, convict:, slot:)

        appointment.book

        visit convict_path(convict)

        within first('.appointment-fulfilment-container') { click_button 'Excusé' }

        appointment.reload
        expect(appointment.state).to eq('excused')
      end
    end
  end

  describe 'replanification', logged_in_as: 'cpip' do
    it 're-schedules an appointment to a later date' do
      convict = create(:convict, organizations: [@user.organization])
      apt_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                     name: "Sortie d'audience SPIP")
      place = create :place, name: 'Test place', appointment_types: [apt_type],
                             organization: @user.organization
      create :agenda, place:, name: 'Agenda de test'
      slot1 = create :slot, appointment_type: apt_type, agenda: @user.organization.agendas.first
      appointment = create(:appointment, convict:, slot: slot1)

      appointment.book
      slot2 = create :slot, agenda: appointment.slot.agenda,
                            appointment_type: apt_type,
                            date: Date.civil(2025, 4, 16),
                            starting_time: new_time_for(14, 0)

      visit appointment_path(appointment)
      click_button 'Replanifier'

      expect(page).to have_content 'Replanifier une convocation'

      choose '14:00'

      click_button 'Enregistrer'

      appointment.reload
      expect(appointment.state).to eq 'canceled'
      expect(appointment.reminder_notif.state).to eq 'canceled'
      expect(appointment.cancelation_notif.state).to eq 'created'
      expect(appointment.history_items).to eq []

      new_appointment = Appointment.find_by(slot: slot2)

      expect(new_appointment.state).to eq 'booked'
      expect(new_appointment.history_items.count).to eq 4
      expect(new_appointment.reschedule_notif.state).to eq 'programmed'
      expect(SmsDeliveryJob).to have_been_enqueued.once.with(
        Notification.find_by(role: :reschedule, appointment: Appointment.last).id
      )
    end

    it 're-schedules an appointment to a later date without sending SMS if needed' do
      convict = create(:convict, organizations: [@user.organization])
      apt_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                     name: "Sortie d'audience SPIP")
      place = create :place, name: 'Test place', appointment_types: [apt_type],
                             organization: @user.organization
      create :agenda, place:, name: 'Agenda de test'
      slot1 = create :slot, appointment_type: apt_type, agenda: @user.organization.agendas.first
      appointment = create(:appointment, convict:, slot: slot1)

      appointment.book
      slot2 = create :slot, agenda: appointment.slot.agenda,
                            appointment_type: apt_type,
                            date: Date.civil(2025, 4, 16),
                            starting_time: new_time_for(14, 0)

      visit appointment_path(appointment)
      click_button 'Replanifier'

      expect(page).to have_content 'Replanifier une convocation'

      choose '14:00'
      choose 'Envoyer uniquement un rappel par SMS avant la convocation'

      click_button 'Enregistrer'

      appointment.reload
      expect(appointment.state).to eq 'canceled'
      expect(appointment.reminder_notif.state).to eq 'canceled'
      expect(appointment.cancelation_notif.state).to eq 'created'
      expect(appointment.history_items).to eq []

      new_appointment = Appointment.find_by(slot: slot2)

      expect(new_appointment.state).to eq 'booked'
      expect(new_appointment.history_items.count).to eq 3
      expect(new_appointment.reschedule_notif.state).to eq 'created'
      expect(SmsDeliveryJob).not_to have_been_enqueued.with(
        Notification.find_by(role: :reschedule, appointment: Appointment.last).id
      )
    end

    it 'works for an appointment type without pre defined slots' do
      convict = create(:convict, organizations: [@user.organization])
      apt_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                     name: 'Convocation de suivi SPIP')
      place = create :place, name: 'Test place', appointment_types: [apt_type],
                             organization: @user.organization
      create :agenda, place:, name: 'Agenda de test'
      slot = create(:slot, :without_validations, appointment_type: apt_type,
                                                 agenda: @user.organization.agendas.first)
      appointment = create(:appointment, convict:, slot:)

      appointment.book

      visit appointment_path(appointment)
      click_button 'Replanifier'

      expect(page).to have_content 'Replanifier une convocation'

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
      expect(new_appointment.reschedule_notif.state).to eq 'programmed'
    end
  end
end
