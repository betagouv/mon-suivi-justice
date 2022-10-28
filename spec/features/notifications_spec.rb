require 'rails_helper'

RSpec.feature 'Notifications', type: :feature do
  before do
    @user = create_admin_user_and_login
    # TODO : we should not have to return Place.all. The factory should add places to the user's organization
    allow(Place).to receive(:in_departments).and_return(Place.all)
  end

  describe 'Reminder' do
    let(:adapter_dbl) { instance_double LinkMobilityAdapter, send_sms: true }

    it "is programmed even if the convict don't have a phone", js: true do
      allow(LinkMobilityAdapter).to receive(:new).and_return adapter_dbl

      convict = create(:convict, first_name: 'Bobby', last_name: 'Lapointe', phone: '', no_phone: true)
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
      appointment_type = create :appointment_type, :with_notification_types, name: 'RDV de suivi SPIP'
      place = create :place, name: 'SPIP de Thorigné', appointment_types: [appointment_type],
                             organization: @user.organization
      create :agenda, place: place, name: 'Agenda du SPIP de Thorigné'

      visit new_appointment_path

      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'LAPOINTE Bobby').click

      select 'RDV de suivi SPIP', from: :appointment_appointment_type_id
      select 'SPIP de Thorigné', from: 'Lieu'

      fill_in 'appointment_slot_date', with: Date.civil(2025, 4, 18).strftime('%Y-%m-%d')

      within first('.form-time-select-fields') do
        select '15', from: 'appointment_slot_starting_time_4i'
        select '00', from: 'appointment_slot_starting_time_5i'
      end

      click_button 'Enregistrer'

      expect(SmsDeliveryJob).to have_been_enqueued.once
    end
  end
end
