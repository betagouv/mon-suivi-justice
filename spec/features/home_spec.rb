require 'rails_helper'

RSpec.feature 'Home', type: :feature do
  describe 'Home page' do
    it 'loads' do
      allow(DataCollector).to receive(:perform)
      jap_user = create(:user, role: :jap)
      login_user(jap_user)

      visit home_path

      expect(page).to have_content('Trouver une PPSMJ')
    end
  end
end
