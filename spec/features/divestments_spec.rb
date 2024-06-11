require 'rails_helper'

RSpec.feature 'Divestments', type: :feature do
  describe 'creation' do
    context 'appointment_type with predefined slots' do
      before do
        @convict = create(:convict, first_name: 'Joe', last_name: 'Dalton')
        create(:user, role: :local_admin, organization: @convict.organizations.last)
        organization = @convict.organizations.last
        place = create(:place, organization:)
        agenda = create(:agenda, place:)
        slot = build(:slot, agenda:, date: 2.month.ago)
        slot.save(validate: false)
        appointment = build(:appointment, convict: @convict, slot:)
        appointment.save(validate: false)
      end

      it 'allows user to create a divestment', logged_in_as: 'cpip', js: true do
        visit new_convict_path

        fill_in 'N° dossier APPI', with: @convict.appi_uuid

        expect { click_button 'submit-with-appointment' }.not_to(change { Convict.count })

        expect(page).to have_content('Attention : ce probationnaire existe déjà')

        accept_alert do
          click_button('Créer un dessaisissement')
        end

        expect(page).to have_content('La demande de dessaisissement a bien été créée')

        expect(Divestment.count).to eq(1)
        expect(OrganizationDivestment.count).to eq(1)

        divestment = @convict.divestments.last
        organization_divestment = divestment.organization_divestments.last
        expect(organization_divestment.state).to eq('pending')
        expect(organization_divestment.organization).to eq(@convict.organizations.last)
      end
    end
  end
end
