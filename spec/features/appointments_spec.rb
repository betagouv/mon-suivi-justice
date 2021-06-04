require 'rails_helper'

RSpec.feature 'Appointments', type: :feature, focus: true do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    it 'lists all appointments' do
      create(:appointment, date: '06/06/2021')
      create(:appointment, date: '08/08/2021')

      visit appointments_path

      expect(page).to have_content('06/06/2021')
      expect(page).to have_content('08/08/2021')
    end
  end
end
