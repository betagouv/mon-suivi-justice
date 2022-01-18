require 'rails_helper'

RSpec.feature 'Steering', type: :feature do
  describe 'show' do
    it 'loads' do
      create_admin_user_and_login

      visit steering_path

      expect(page).to have_content('Global')
    end
  end
end
