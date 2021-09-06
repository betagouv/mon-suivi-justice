require 'rails_helper'

RSpec.feature 'Static Pages', type: :feature do
  describe 'secret landing' do
    it 'loads on the right path' do
      visit secret_path
      expect(page).to have_current_path '/secret'
    end
  end
end
