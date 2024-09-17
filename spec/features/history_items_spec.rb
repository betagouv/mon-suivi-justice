require 'rails_helper'

RSpec.feature 'HistoryItems', type: :feature do
  describe 'for a Convict', logged_in_as: 'cpip' do
    let(:convict) { create(:convict, phone: nil, refused_phone: true, organizations: [@user.organization]) }
    let(:appointment) { create_appointment(convict, @user.organization, date: next_valid_day) }

    it 'displays new appointments' do
      expect { appointment.book }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expect(page).to have_content('Nouvelle convocation')
    end

    it 'displays when appointments are fulfiled' do
      appointment.book
      expect { appointment.fulfil }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expect(page).to have_content("s'est bien presenté à sa convocation")
    end

    it 'displays when appointments are missed' do
      appointment.book
      expect { appointment.miss(send_sms: false) }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expect(page).to have_content("ne s'est pas presenté à sa convocation")
    end

    it 'displays when convict is archived' do
      expect do
        Capybara.current_session.driver.delete convict_archive_path(convict)
      end.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expect(page).to have_content('a été archivé. Pour le désarchiver, contactez votre administrateur local.')
    end

    it 'displays when convict is unarchived', logged_in_as: 'local_admin', js: true do
      convict.discard

      visit convicts_path
      within first('tbody > tr') do
        expect { click_link('Désarchiver') }.to change { HistoryItem.count }.by(1)
      end

      visit convict_path(convict)

      expect(page).to have_content('a été désarchivé.')
    end
  end

  describe 'for an appointment', logged_in_as: 'cpip' do
    before do
      @convict = create(:convict, phone: nil, refused_phone: true, organizations: [@user.organization])
      @appointment_type = build(:appointment_type, name: 'Convocation de suivi SPIP')
      @slot = create(:slot, appointment_type: @appointment_type)
      @appointment = create(:appointment, convict: @convict, creating_organization: @user.organization, slot: @slot)
      @summon_notif = create(:notification, appointment: @appointment,
                                            role: 'summon',
                                            content: 'Vous êtes encore convoqué...')

      @reminder_notif = create(:notification, appointment: @appointment,
                                              role: 'reminder',
                                              state: 'programmed',
                                              content: 'RAPPEL Vous êtes encore convoqué...',
                                              external_id: '1')

      @cancelation_notif = create(:notification, appointment: @appointment,
                                                 role: 'cancelation',
                                                 content: 'Finalement non :/')

      @no_show_notif = create(:notification, appointment: @appointment,
                                             role: 'no_show',
                                             content: "Sérieusement, vous n'êtes pas venu ?")
    end

    it 'displays summon notification content' do
      expect { @summon_notif.program_now }.to change { HistoryItem.count }.by(1)

      visit appointment_path(@appointment)

      expect(page).to have_content('Vous êtes encore convoqué...')
    end

    it 'displays reminder notification content' do
      expect { @reminder_notif.mark_as_sent }.to change { HistoryItem.count }.by(1)

      visit appointment_path(@appointment)

      expect(page).to have_content('RAPPEL Vous êtes encore convoqué...')
    end

    it 'displays cancelation notification content' do
      expect { @cancelation_notif.program_now }.to change { HistoryItem.count }.by(1)

      visit appointment_path(@appointment)

      expect(page).to have_content('Finalement non :/')
    end

    it 'displays no_show notification content' do
      expect { @no_show_notif.program_now }.to change { HistoryItem.count }.by(1)

      visit appointment_path(@appointment)

      expect(page).to have_content("Sérieusement, vous n'êtes pas venu ?")
    end
  end
end
