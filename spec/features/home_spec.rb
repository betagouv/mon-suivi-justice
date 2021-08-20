require 'rails_helper'

RSpec.feature 'Home', type: :feature do
  describe 'Home page' do
    it 'allows to find a convict' do
      create_admin_user_and_login

      visit home_path

      expect(page).to have_content('Trouver une PPSMJ')
    end
  end
end
