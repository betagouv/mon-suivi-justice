require 'rails_helper'

RSpec.feature 'Steering', type: :feature do
  describe 'user_app_stats' do
    it 'loads' do
      create_admin_user_and_login

      visit steering_user_app_path

      expect(page).to have_content('Global')
    end
  end

  describe 'convict_app_stats' do
    it 'loads' do
      create_admin_user_and_login

      visit steering_convict_app_path

      expect(page).to have_content('Total PPSMJ invitées')
    end
  end
end
