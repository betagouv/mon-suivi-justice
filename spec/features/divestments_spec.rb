require 'rails_helper'

RSpec.feature 'Divestments', type: :feature do
  describe 'creation', js: true do
    context 'appointment_type with predefined slots' do
      before do
        @convict = create(:convict, first_name: 'Joe', last_name: 'Dalton', appi_uuid: '123456789')
      end

      it 'allows user to create a divestment', logged_in_as: 'cpip' do
        visit new_convict_path

        fill_in 'N° dossier APPI', with: '123456789'

        expect { click_button 'submit-with-appointment' }.not_to(change { Convict.count })

        within 'div.fr-alert.fr-alert--warning' do
          expect(page).to have_content('Attention : ce probationnaire existe déjà')
        end

        accept_alert do
          click_button('Créer un dessaisissement')
        end

        expect(Divestment.count).to eq(1)
      end
    end
  end
end
