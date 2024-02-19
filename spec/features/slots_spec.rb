require 'rails_helper'

RSpec.feature 'Slots', type: :feature, logged_in_as: 'admin' do
  describe 'index' do
    before do
      place = create :place, organization: @user.organization
      @agenda = create(:agenda, place:)
      @apt_type = create(:appointment_type, name: "Sortie d'audience SPIP")
      @slot1 = create(:slot, appointment_type: @apt_type, agenda: @agenda, date: Date.civil(2025, 4, 14))
    end

    it 'lists all slots' do
      create(:slot, appointment_type: @apt_type, agenda: @agenda, date: Date.civil(2025, 4, 16))

      visit slots_path

      expect(page).to have_content(Date.civil(2025, 4, 14).to_fs)
      expect(page).to have_content(Date.civil(2025, 4, 16).to_fs)
    end

    it 'allows to close slot' do
      visit slots_path

      within first('tbody > tr') do
        click_link('Fermer')
      end

      @slot1.reload
      expect(@slot1.available).to eq(false)
      expect(page).not_to have_content(Date.civil(2025, 4, 18).to_fs)
    end
  end

  describe 'creation' do
    before do
      place = create(:place, name: 'McDo de Clichy', organization: @user.organization)
      @agenda = create(:agenda, place:, name: 'Agenda de Michel')
      @appointment_type = create(:appointment_type, name: "Sortie d'audience SPIP")
      create(:place_appointment_type, place:, appointment_type: @appointment_type)

      create(:appointment_type, name: 'Convocation de suivi SPIP')
    end

    it 'creates one slot', js: true do
      visit new_slots_batch_path

      select 'Agenda de Michel', from: 'Agenda'
      expect(page).to have_select('Type de convocation', options: ['', "Sortie d'audience SPIP"])
      select "Sortie d'audience SPIP", from: 'Type de convocation'

      find('#slot_batch_date').click
      find('.flatpickr-day', text: next_valid_day.day).click

      click_on 'Créneau unique'

      within first('.form-time-select-fields') do
        select '15', from: 'slot_batch_starting_time_4i'
        select '00', from: 'slot_batch_starting_time_5i'
      end

      fill_in 'Durée', with: '40'
      fill_in 'Capacité', with: '10'

      expect { click_button 'Enregistrer' }.to change { Slot.count }.by(1)

      created_slot = Slot.last

      expect(created_slot.agenda).to eq(@agenda)
      expect(created_slot.appointment_type).to eq(@appointment_type)
      expect(created_slot.appointment_type).to eq(@appointment_type)
      expect(created_slot.date).to eq(next_valid_day)

      time_zone = TZInfo::Timezone.get('Europe/Paris')
      expect(time_zone.to_local(created_slot.starting_time).hour).to eq(15)
      expect(created_slot.starting_time.min).to eq(0)
      expect(created_slot.duration).to eq(40)
      expect(created_slot.capacity).to eq(10)
    end

    it 'creates a batch of slots', js: true do
      visit new_slots_batch_path

      select 'Agenda de Michel', from: 'Agenda'
      expect(page).to have_select('Type de convocation', options: ['', "Sortie d'audience SPIP"])
      select "Sortie d'audience SPIP", from: 'Type de convocation'

      find('#slot_batch_date').click
      find('.flatpickr-day', text: next_valid_day.day).click

      click_on 'Créneau unique'

      within first('.form-time-select-fields') do
        select '15', from: 'slot_batch_starting_time_4i'
        select '00', from: 'slot_batch_starting_time_5i'
      end

      click_on 'Plage de créneaux'

      within all('.slot_batch_interval_time').last do
        select '16', from: 'slot_batch_start_time_4i'
        select '00', from: 'slot_batch_start_time_5i'

        select '16', from: 'slot_batch_end_time_4i'
        select '30', from: 'slot_batch_end_time_5i'

        fill_in 'interval_1i', with: '15'
      end

      fill_in 'Durée', with: 40
      fill_in 'Capacité', with: 10
      expect { click_button 'Enregistrer' }.to change { Slot.count }.by(4)
      # Generate a test to check the slots are created with the right time
      expect(Slot.last(4).map(&:starting_time)).to match_array([Time.zone.parse('2000-01-01 15:00:00 +01:00'),
                                                                Time.zone.parse('2000-01-01 16:00:00 +01:00'),
                                                                Time.zone.parse('2000-01-01 16:15:00 +01:00'),
                                                                Time.zone.parse('2000-01-01 16:30:00 +01:00')])
    end
  end

  describe 'edition' do
    before do
      @apt_type = create(:appointment_type, name: "Sortie d'audience SPIP")
      place = create(:place, organization: @user.organization)
      agenda = create(:agenda, place:)
      @slot1 = create(:slot, appointment_type: @apt_type, date: Date.civil(2025, 4, 14), agenda:)
    end

    it 'works' do
      visit edit_slot_path(@slot1.id)
      fill_in 'Capacité', with: 7
      click_button 'Enregistrer'
      @slot1.reload
      expect(@slot1.capacity).to eq(7)
    end

    it 'prevents user from filling in a capacity which is lower than used_capacity' do
      @slot1.capacity = 10
      @slot1.used_capacity = 5
      @slot1.save

      visit edit_slot_path(@slot1.id)
      fill_in 'Capacité', with: 4
      click_button 'Enregistrer'

      @slot1.reload

      expect(@slot1.capacity).to eq(10)
    end
  end

  describe 'batch close' do
    it 'allows to select slots to close' do
      place = create :place, organization: @user.organization
      agenda = create(:agenda, place:)
      apt_type = AppointmentType.create(name: "Sortie d'audience SPIP")

      slot1 = create(:slot, appointment_type: apt_type, agenda:, starting_time: new_time_for(9, 0))
      slot2 = create(:slot, appointment_type: apt_type, agenda:, starting_time: new_time_for(9, 0))
      slot3 = create(:slot, appointment_type: apt_type, agenda:, starting_time: new_time_for(9, 0))
      slot4 = create(:slot, appointment_type: apt_type, agenda:, starting_time: new_time_for(10, 0))
      slot5 = create(:slot, appointment_type: apt_type, agenda:, starting_time: new_time_for(10, 0))

      visit slots_path

      check "slot_#{slot1.id}"
      check "slot_#{slot2.id}"
      check "slot_#{slot3.id}"

      expect { click_button 'Fermer la sélection' }.not_to(change { Slot.count })

      expect(slot1.reload.available).to eq(false)
      expect(slot2.reload.available).to eq(false)
      expect(slot3.reload.available).to eq(false)
      expect(slot4.reload.available).to eq(true)
      expect(slot5.reload.available).to eq(true)
    end
  end
end
