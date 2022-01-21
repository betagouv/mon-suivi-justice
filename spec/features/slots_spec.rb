require 'rails_helper'

RSpec.feature 'Slots', type: :feature do
  before do
    create_admin_user_and_login
    allow(Place).to receive(:in_department).and_return(Place.all)
  end

  describe 'index' do
    before do
      @slot1 = create(:slot, date: (Date.today + 2).to_s)
      create(:slot, date: (Date.today + 4).to_s)

      visit slots_path
    end

    it 'lists all places' do
      expect(page).to have_content((Date.today + 2).to_s)
      expect(page).to have_content((Date.today + 4).to_s)
    end

    it 'allows to close slot' do
      within first('.slots-item-container') do
        click_link('Fermer')
      end

      @slot1.reload
      expect(@slot1.available).to eq(false)
      expect(page).not_to have_content((Date.today + 2).to_s)
    end
  end

  describe 'creation' do
    it 'works' do
      place = create(:place, name: 'McDo de Clichy', organization: @user.organization)
      create(:agenda, place: place, name: 'Agenda de Michel')
      create(:appointment_type, name: "Sortie d'audience SPIP")
      create(:appointment_type, name: 'RDV de suivi SPIP')

      visit new_slot_path

      select 'Agenda de Michel', from: 'Agenda'
      expect(page).to have_select('Type de rendez-vous', options: ['', "Sortie d'audience SPIP"])
      select "Sortie d'audience SPIP", from: 'Type de rendez-vous'

      within '.form-date-select-fields' do
        select '14', from: 'slot_date_3i'
        select 'octobre', from: 'slot_date_2i'
        select '2024', from: 'slot_date_1i'
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
