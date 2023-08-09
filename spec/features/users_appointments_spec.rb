require 'rails_helper'

RSpec.feature 'Users::Appointments', type: :feature do
  describe 'index', logged_in_as: 'cpip' do
    it 'displays user appointments' do
      place = create :place, organization: @user.organization
      agenda = create(:agenda, place:)

      user2 = create(:user, role: :cpip, organization: @user.organization)

      slot1 = create(:slot, agenda:,
                            date: Date.civil(2025, 4, 14),
                            starting_time: new_time_for(13, 0))

      slot2 = create(:slot, agenda:,
                            date: Date.civil(2025, 4, 16),
                            starting_time: new_time_for(15, 30))

      slot3 = create(:slot, agenda:,
                            date: Date.civil(2025, 4, 18),
                            starting_time: new_time_for(17, 30))

      convict = create(:convict, user: @user)
      convict2 = create(:convict, user: user2)
      create(:appointment, convict:, user: @user, slot: slot1)
      create(:appointment, convict:, user: @user, slot: slot2)
      create(:appointment, convict: convict2, user: user2, slot: slot3)

      visit user_appointments_path

      expect(page).to have_content(Date.civil(2025, 4, 14))
      expect(page).to have_content('13:00')
      expect(page).to have_content(Date.civil(2025, 4, 16))
      expect(page).to have_content('15:30')
      expect(page).not_to have_content(Date.civil(2025, 4, 18))
      expect(page).not_to have_content('17:30')
    end
  end
end
