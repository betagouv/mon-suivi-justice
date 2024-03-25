require 'rails_helper'

RSpec.feature 'OrganizationStatistics', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    it 'loads' do
      visit organization_statistics_path

      expect(page).to have_content('Statistiques')
    end
  end
end
