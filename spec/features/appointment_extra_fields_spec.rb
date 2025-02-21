require 'rails_helper'

RSpec.feature 'ExtraFields', type: :feature, js: true do
  describe 'appointment creation with extra_fields', logged_in_as: 'bex' do
    let(:organization_a) { @user.organization }

    let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

    let(:extra_field_a) do
      create(:extra_field, name: 'Extra field A', organization: organization_a, data_type: 'text',
                           scope: 'appointment_create',
                           appointment_types: [appointment_type])
    end

    let(:place_a) do
      create(:place, name: 'Place A', organization: organization_a, appointment_types: [appointment_type])
    end

    let(:agenda_a) { create(:agenda, name: 'Agenda A', place: place_a) }

    let(:slot_a) do
      create(:slot, agenda: agenda_a, appointment_type:, date: next_valid_day(date: Date.today),
                    starting_time: new_time_for(14, 0))
    end

    let(:organization_b) { create(:organization, name: 'Organization B', organization_type: 'tj') }

    let(:extra_field_b) do
      create(:extra_field, name: 'Extra field B', organization: organization_b, data_type: 'text',
                           scope: 'appointment_create',
                           appointment_types: [appointment_type])
    end

    let(:organization_c) { create(:organization, name: 'Organization C', organization_type: 'tj') }

    let(:convict) { create(:convict, organizations: [organization_a, organization_b]) }

    before do
      organization_a
      appointment_type
      extra_field_a
      place_a
      agenda_a
      slot_a
      organization_b
      extra_field_b
      organization_c
      convict
    end

    it 'displays proper extra fields in appointment form' do
      visit new_appointment_path({ convict_id: convict })

      select "Sortie d'audience SAP", from: :appointment_appointment_type_id
      select 'Place A', from: 'Lieu'

      fill_in 'appointment_appointment_extra_fields_attributes_0_value', with: 'Test content extra field A'

      choose '14:00'

      expect(page).to have_content('Extra field A')
      expect(page).not_to have_content('Extra field B')
    end

    it 'creates proprer appointment extra field' do
      visit new_appointment_path({ convict_id: convict })

      select "Sortie d'audience SAP", from: :appointment_appointment_type_id
      select 'Place A', from: 'Lieu'

      fill_in 'appointment_appointment_extra_fields_attributes_0_value', with: 'Test content extra field A'

      choose '14:00'

      page.find('label[for="send_sms_1"]').click

      click_button 'Convoquer'
      last_appointment = Appointment.last
      last_appointment_extra_field = AppointmentExtraField.last

      expect(last_appointment_extra_field.appointment_id).to eq(last_appointment.id)
      expect(last_appointment_extra_field.value).to eq('Test content extra field A')
    end

    it 'displays extra fields in agenda for Organization A' do
      visit new_appointment_path({ convict_id: convict })

      select "Sortie d'audience SAP", from: :appointment_appointment_type_id
      select 'Place A', from: 'Lieu'

      fill_in 'appointment_appointment_extra_fields_attributes_0_value', with: 'Test content extra field A'

      choose '14:00'

      page.find('label[for="send_sms_1"]').click

      click_button 'Convoquer'

      orga_a_bex_user = create(:user, role: :bex, organization: organization_a)
      login_as(orga_a_bex_user)

      month = (I18n.l slot_a.date, format: '%B %Y').capitalize

      visit agenda_jap_path

      select month, from: :date

      expect(page).to have_selector('th', text: extra_field_a.name)
      expect(page).to have_selector('td', text: AppointmentExtraField.last.value)
    end
  end
end
