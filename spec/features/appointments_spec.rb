require 'rails_helper'

RSpec.feature 'Appointments', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    it 'lists all appointments' do
      slot_1 = create(:slot, date: '06/06/2021', starting_time: Time.new(2021,6,21,13,00,0,"+00:00"))
      slot_2 = create(:slot, date: '08/08/2021', starting_time: Time.new(2021,6,21,15,30,0,"+00:00"))

      create(:appointment, slot: slot_1)
      create(:appointment, slot: slot_2)

      visit appointments_path

      expect(page).to have_content('06/06/2021')
      expect(page).to have_content('13:00')
      expect(page).to have_content('08/08/2021')
      expect(page).to have_content('15:30')
    end
  end
end
