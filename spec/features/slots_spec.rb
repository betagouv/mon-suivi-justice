require 'rails_helper'

RSpec.feature 'Slots', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    before do
      create(:slot, date: '10/10/2021')
      create(:slot, date: '23/10/2021')

      visit slots_path
    end

    it 'lists all places' do
      expect(page).to have_content('10/10/2021')
      expect(page).to have_content('23/10/2021')
    end

    it 'allows to delete slot' do
      within first('.slots-item-container') do
        expect { click_link('Supprimer') }.to change { Slot.count }.by(-1)
      end
    end
  end

  describe 'creation' do
    it 'works' do
      create(:place, name: 'McDo de Clichy')

      visit new_slot_path

      select 'McDo de Clichy', from: 'Lieu'

      within '.form-date-select-fields' do
        select '14', from: 'slot_date_3i'
        select 'octobre', from: 'slot_date_2i'
        select '2021', from: 'slot_date_1i'
      end

      within first('.form-time-select-fields') do
        select '15', from: 'slot_starting_time_4i'
        select '00', from: 'slot_starting_time_5i'
      end

      expect { click_button 'Créer Créneau' }.to change { Slot.count }.by(1)
    end
  end
end
