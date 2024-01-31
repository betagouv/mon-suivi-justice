require 'rails_helper'

RSpec.feature 'Divestments', type: :feature do
  describe 'creation' do
    context 'appointment_type with predefined slots' do
      before do
        @convict = create(:convict, first_name: 'Joe', last_name: 'Dalton', appi_uuid: '123456789')
        create(:user, role: :local_admin, organization: @convict.organizations.last)
      end

      it 'allows user to create a divestment', logged_in_as: 'cpip', js: true do
        visit new_convict_path

        fill_in 'N° dossier APPI', with: '123456789'

        expect { click_button 'submit-with-appointment' }.not_to(change { Convict.count })

        expect(page).to have_content('Attention : ce probationnaire existe déjà')

        accept_alert do
          click_button('Créer un dessaisissement')
        end

        expect(page).to have_content('Les demandes des dessaisissements ont bien été créées')

        expect(Divestment.count).to eq(1)
        expect(OrganizationDivestment.count).to eq(1)

        organization_divestment = OrganizationDivestment.last
        expect(organization_divestment.state).to eq('pending')
        expect(organization_divestment.organization).to eq(@convict.organizations.last)
      end
    end
  end
end
