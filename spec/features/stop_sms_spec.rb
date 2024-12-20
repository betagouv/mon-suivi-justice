require 'rails_helper'

RSpec.feature 'Stop SMS', type: :feature do
  let(:invalid_token) { 'invalid_token' }
  let(:convict) { create(:convict, refused_phone: false) }
  let(:valid_token) { convict.unsubscribe_token }

  describe 'Visiting stop_sms page' do
    context 'with valid token' do
      it 'displays the unsubscribe confirmation message and button' do
        visit stop_sms_path(token: valid_token)

        expect(page).to have_content('Désinscription des SMS')
        expect(page).to have_content('Je confirme ne pas souhaiter recevoir de SMS')
        expect(page).to have_button('Confirmer la désinscription')
      end
    end

    context 'with invalid token' do
      it 'displays an error message' do
        visit stop_sms_path(token: invalid_token)

        expect(page).to have_content('Désinscription des SMS')
        expect(page).to have_content('Token invalide ou expiré.')
      end
    end
  end

  describe 'Confirming unsubscribe' do
    context 'with valid token' do
      it 'updates refused_phone to true and displays success message' do
        visit stop_sms_path(token: valid_token)

        click_button 'Confirmer la désinscription'

        expect(convict.reload.refused_phone).to be true

        # cant figure out how to handle turbo with with so raw html it is
        response_body = page.driver.response.body
        expect(response_body).to include('Votre demande de désinscription a bien été prise en compte')
      end
    end
  end
end
