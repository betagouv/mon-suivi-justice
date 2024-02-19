require 'rails_helper'

RSpec.describe 'Security Charter Acceptance', type: :feature, logged_in_as: 'no_security_charter' do
  let(:alert_content) do
    'Vous devez accepter la charte de sécurité pour continuer à utiliser Mon Suivi Justice.'
  end
  let(:notice_content) do
    "Merci d'avoir accepté notre charte de sécurité. Vous pouvez désormais utiliser Mon Suivi Justice librement."
  end
  it 'redirects to the new_security_charter_acceptance page from any page' do
    expect(@user.reload.security_charter_accepted_at).to be_nil
    visit home_path
    expect(page).to have_current_path(new_security_charter_acceptance_path)
    expect(page).to have_content(alert_content)
    visit convicts_path
    expect(page).to have_current_path(new_security_charter_acceptance_path)
    expect(page).to have_content(alert_content)
  end

  context 'when user clicks on the accept button' do
    before do
      visit new_security_charter_acceptance_path
      click_button "J'accepte la charte de sécurité"
    end

    it 'redirects to the root_path with a notice' do
      expect(page).to have_current_path(root_path)
      expect(page).to have_content(notice_content)
    end

    it 'updates the security_charter_accepted_at attribute' do
      expect(@user.reload.security_charter_accepted_at).not_to be_nil
      expect(@user.reload.security_charter_accepted_at).to be <= Time.current
    end
  end
end
