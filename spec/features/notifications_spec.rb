require 'rails_helper'

RSpec.feature 'Notifications', type: :feature do
  before do
    @user = create_admin_user_and_login
  end

  describe 'Reminder' do
    let(:adapter_dbl) { instance_double LinkMobilityAdapter, send_sms: true }

    it "is programmed even if the convict don't have a phone", js: true do
      allow(LinkMobilityAdapter).to receive(:new).and_return adapter_dbl

      @convict = create(:convict, first_name: 'Bobby', last_name: 'Lapointe', phone: '', no_phone: true,
                                  organizations: [@user.organization])
      appointment_type = create :appointment_type, :with_notification_types, name: 'Convocation de suivi SPIP'
      place = create :place, name: 'SPIP de Thorigné', appointment_types: [appointment_type],
                             organization: @user.organization
      create :agenda, place:, name: 'Agenda du SPIP de Thorigné'

      visit new_appointment_path({ convict_id: @convict.id })

      select 'Convocation de suivi SPIP', from: :appointment_appointment_type_id
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
