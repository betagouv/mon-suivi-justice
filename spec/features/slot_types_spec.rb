require 'rails_helper'

RSpec.feature 'SlotTypes', type: :feature, logged_in_as: 'admin' do
  before do
    place = create :place, name: 'test_place_name', organization: @user.organization
    @agenda = create :agenda, place:, name: 'test_agenda_name'
    @appointment_type = create :appointment_type, name: "Sortie d'audience SPIP"
    create :place_appointment_type, place:, appointment_type: @appointment_type
  end

  describe 'index' do
    it 'lists slot_types for an agenda', js: true do
      slot_type1 = create :slot_type, week_day: 'monday', starting_time: new_time_for(10, 0),
                                      duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda
      slot_type2 = create :slot_type, week_day: 'tuesday', starting_time: new_time_for(16, 0),
                                      duration: 60, capacity: 3, appointment_type: @appointment_type, agenda: @agenda

      visit places_path

      within first('tbody > tr') do
        click_link 'Modifier'
      end

      click_link 'Créneaux récurrents'

      expect(page).to have_content 'Créneaux récurrents'
      expect(page).to have_content 'test_place_name : test_agenda_name'
      expect(page).to have_content "Sortie d'audience SPIP"
      expect(page).to have_css "#edit_slot_type_#{slot_type1.id}"
      expect(page).to have_css "#edit_slot_type_#{slot_type2.id}"
    end
  end

  describe 'edition' do
    it 'allows admin to edit slot_types' do
      slot_type = create :slot_type, week_day: 'monday', starting_time: new_time_for(10, 0),
                                     duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda

      visit agenda_slot_types_path(@agenda)

      within "#edit_slot_type_#{slot_type.id}" do
        fill_in :slot_type_duration, with: 23
        fill_in :slot_type_capacity, with: 6
        click_button 'Enregistrer'
      end

      expect(
        SlotType.find_by(
          id: slot_type.id, appointment_type: @appointment_type, agenda: @agenda,
          week_day: 'monday', duration: 23, capacity: 6
        )
      ).not_to be_nil
    end

    it 'does not edit a slot_type with attributes that already exists' do
      slot_type = create(:slot_type, week_day: 'monday', starting_time: new_time_for(14, 0),
                                     duration: 30, capacity: 1, appointment_type: @appointment_type,
                                     agenda: @agenda)
      create(:slot_type, week_day: 'monday', starting_time: new_time_for(15, 0), duration: 30,
                         capacity: 1, appointment_type: @appointment_type, agenda: @agenda)

      visit agenda_slot_types_path(@agenda)

      within first("#edit_slot_type_#{slot_type.id}") do
        select '15', from: 'slot_type_starting_time_4i'
        select '00', from: 'slot_type_starting_time_5i'
        click_button 'Enregistrer'
      end

      expect(page).to have_content('Un créneau récurrent similaire existe déjà')
      expect(slot_type.starting_time).to eq('Sat, 01 Jan 2000 14:00:00.000000000 CET +01:00'.to_time)
    end
  end

  describe 'creation' do
    it 'works for a single slot_type' do
      visit agenda_slot_types_path(@agenda)

      within first('#new_slot_type') do
        fill_in :slot_type_duration, with: 23
        fill_in :slot_type_capacity, with: 6
        click_button 'Ajouter'
      end

      expect(
        SlotType.find_by(
          appointment_type: @appointment_type, agenda: @agenda,
          week_day: 'monday', duration: 23, capacity: 6
        )
      ).not_to be_nil
    end

    it 'does not create a slot_type that already exists' do
      create(:slot_type, week_day: 'monday', starting_time: new_time_for(14, 0),
                         duration: 30, capacity: 10, agenda: @agenda, appointment_type: @appointment_type)

      visit agenda_slot_types_path(@agenda)
      within first('#new_slot_type') do
        fill_in :slot_type_duration, with: 23
        fill_in :slot_type_capacity, with: 6
        select '14', from: 'slot_type_starting_time_4i'
        select '00', from: 'slot_type_starting_time_5i'
        click_button 'Ajouter'
      end

      expect(page).to have_content('Un créneau récurrent similaire existe déjà')
      expect(SlotType.count).to eq(1)
    end
  end

  describe 'deletion' do
    it 'works' do
      slot_type = create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
                                     duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda

      visit agenda_slot_types_path(@agenda)
      within "#edit_slot_type_#{slot_type.id}"

      expect { click_link 'Supprimer' }.to change(SlotType, :count).from(1).to(0)
    end
  end

  describe 'batch actions' do
    it 'creates batches of slot_types' do
      visit agenda_slot_types_path(@agenda)

      within first('.slot-type-batch-creator-container') do
        check 'lundi'
        select '09', from: 'slot_types_batch_first_slot_4i'
        select '00', from: 'slot_types_batch_first_slot_5i'

        select '12', from: 'slot_types_batch_last_slot_4i'
        select '00', from: 'slot_types_batch_last_slot_5i'

        fill_in 'Intervalle', with: 30
        fill_in 'Capacité', with: 6
        fill_in 'Durée', with: 30
      end

      expect { click_button 'Tout créer' }.to change(SlotType, :count).by(7)
    end

    it 'deletes all slot_types for an agenda' do
      3.times { create :slot_type, agenda: @agenda }

      visit agenda_slot_types_path(@agenda)

      within first('.slot-type-batch-creator-container') do
        expect { click_link 'Tout supprimer' }.to change(SlotType, :count).by(-3)
      end
    end

    it 'deletes slot_types for a specific day' do
      2.times { create :slot_type, agenda: @agenda, appointment_type: @appointment_type, week_day: 'monday' }
      2.times { create :slot_type, agenda: @agenda, appointment_type: @appointment_type, week_day: 'tuesday' }

      visit agenda_slot_types_path(@agenda)

      within first('.index-slot-types-weekday-wrapper-monday') do
        expect { click_link 'Tout supprimer' }.to change(SlotType, :count).by(-2)
      end
    end

    it 'does not create slot type with zero interval' do
      visit agenda_slot_types_path(@agenda)

      within first('.slot-type-batch-creator-container') do
        check 'lundi'
        select '09', from: 'slot_types_batch_first_slot_4i'
        select '00', from: 'slot_types_batch_first_slot_5i'

        select '12', from: 'slot_types_batch_last_slot_4i'
        select '00', from: 'slot_types_batch_last_slot_5i'

        fill_in 'Intervalle', with: 0
        fill_in 'Capacité', with: 6
        fill_in 'Durée', with: 30
      end

      expect { click_button 'Tout créer' }.to change(SlotType, :count).by(0)
      expect(page).to have_content('Impossible de créer des créneaux récurrents avec un intervalle de 0 minute')
    end
  end
end
