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
      place = create(:place, name: 'McDo de Clichy')
      create(:agenda, place: place, name: 'Agenda de Michel')
      create(:appointment_type, name: 'Premier contact Spip')

      visit new_slot_path

      select 'Agenda de Michel', from: 'Agenda'
      select 'Premier contact Spip', from: 'Type de rendez-vous'

      within '.form-date-select-fields' do
        select '14', from: 'slot_date_3i'
        select 'octobre', from: 'slot_date_2i'
        select '2021', from: 'slot_date_1i'
      end

      within first('.form-time-select-fields') do
        select '15', from: 'slot_starting_time_4i'
        select '00', from: 'slot_starting_time_5i'
      end

      expect { click_button 'Enregistrer' }.to change { Slot.count }.by(1)

      created_slot = Slot.last

      expect(created_slot.starting_time.hour).to eq(15)
      expect(created_slot.starting_time.min).to eq(0)
    end
  end
end
