require 'rails_helper'

RSpec.feature 'Users::Appointments', type: :feature do
  before do
    create_cpip_user_and_login
  end

  describe 'index' do
    before do
      place = create :place, organization: @user.organization
      @agenda = create :agenda, place: place

      @slot1 = create(:slot, :without_validations, agenda: @agenda,
                                                   date: Date.civil(2025, 4, 14),
                                                   starting_time: new_time_for(13, 0))
      slot2 = create(:slot, agenda: @agenda,
                            date: Date.civil(2025, 4, 16),
                            starting_time: new_time_for(15, 30))
      convict = create(:convict, user: @user)
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      @appointment1 = create(:appointment, :with_notifications, convict: convict, slot: @slot1)
      create(:appointment, convict: convict, slot: slot2)
    end

    it 'displays user appointments' do
      visit user_appointments_path

      expect(page).to have_selector('.index-card-container', count: 2)

      expect(page).to have_content(Date.civil(2025, 4, 14))
      expect(page).to have_content('13:00')
      expect(page).to have_content(Date.civil(2025, 4, 16))
      expect(page).to have_content('15:30')
    end
  end
end
