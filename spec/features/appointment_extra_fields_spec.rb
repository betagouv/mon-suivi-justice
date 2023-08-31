require 'rails_helper'

RSpec.feature 'ExtraFields', type: :feature do
  describe 'appointment creation with extra_fields', logged_in_as: 'bex' do
    let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

    let(:organization_a) { create(:organization, name: 'Organization A', organization_type: 'tj') }
    let(:place_a) do
      create(:place, name: 'Place A', organization: organization_a, appointment_types: [appointment_type])
    end
    let(:agenda_a) { create(:agenda, name: 'Agenda A', place: place_a) }
    let(:slot_a) do
      create(:slot, agenda: agenda_a, appointment_type:, date: Date.civil(2025, 4, 18),
                    starting_time: new_time_for(14, 0))
    end

    let(:organization_b) { create(:organization, name: 'Organization B', organization_type: 'tj') }
    let(:organization_c) { create(:organization, name: 'Organization C', organization_type: 'tj') }

    let(:convict) { create(:convict, organizations: [organization_a, organization_b]) }

    let(:extra_field_a) do
      create(:extra_field, organization: organization_a, data_type: 'text', scope: 'appointment_create')
    end
    let(:extra_field_b) do
      create(:extra_field, organization: organization_b, data_type: 'text', scope: 'appointment_create')
    end

    before do
      appointment_type
      organization_a
      place_a
      organization_b
      organization_c
      convict
      appointment_type
      extra_field_a
      extra_field_b

      visit new_appointment_path({ convict_id: convict })

      select "Sortie d'audience SAP", from: :appointment_appointment_type_id
      select 'Place A', from: 'Lieu'
      select 'agenda_in_name', from: 'Agenda'
      choose '14:00'

      click_button 'Enregistrer et envoyer un SMS'
    end

    it 'displays extra fields in agenda for Organization A' do
      log_in_as(organization_a.bex_user)

      visit agenda_jap_path

      expect(page).to have_selector('th', text: extra_field_a.name)

 
      fill_in 'Date Filter', with: Date.today 
      click_button 'Filter'

      expect(page).to have_selector('td', text: extra_field_a.value)
    end
  end
end
