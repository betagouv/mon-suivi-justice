require 'rails_helper'

RSpec.feature 'HistoryItems', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'for a Convict' do
    it 'record new appointments' do
      convict = create(:convict)
      appointment = create(:appointment, :with_notifications, convict: convict)
      expect { appointment.book }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expect(page).to have_content('Nouveau RDV')
    end

    it 'record when appointments are fulfiled' do
      convict = create(:convict)
      appointment = create(:appointment, :with_notifications, convict: convict, state: 'booked')
      expect { appointment.fulfil }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expect(page).to have_content("s'est bien présenté à son rendez-vous")
    end

    it 'record when appointments are missed' do
      convict = create(:convict)
      appointment = create(:appointment, :with_notifications, convict: convict, state: 'booked')
      expect { appointment.miss }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expect(page).to have_content("ne s'est pas présenté à son rendez-vous")
    end
  end
end
