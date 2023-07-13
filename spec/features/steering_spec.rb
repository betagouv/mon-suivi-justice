require 'rails_helper'

RSpec.feature 'Steering', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'user_app_stats' do
    it 'loads' do
      visit steering_user_app_path

      expect(page).to have_content('Global')
    end
  end

  describe 'sda_stats' do
    it 'loads' do
      visit steering_sda_path

      expect(page).to have_content("Sortie d'audience")
    end
  end

  describe 'convict_app_stats' do
    it 'loads' do
      visit steering_convict_app_path

      expect(page).to have_content('Probationnaires invités')
    end
  end
end
