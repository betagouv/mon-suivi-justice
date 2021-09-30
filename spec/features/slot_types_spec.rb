require 'rails_helper'

RSpec.feature 'SlotTypes', type: :feature do
  before do
    @place = create :place, name: 'test_place_name'
    @agenda = create :agenda, place: @place, name: 'test_agenda_name'
    @appointment_type = create :appointment_type, name: 'apt_type_name'
    create :place_appointment_type, place: @place, appointment_type: @appointment_type
  end

  scenario 'An admin consults slot types' do
    create_admin_user_and_login
    slot_type1 = create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
                                   duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda
    slot_type2 = create :slot_type, week_day: 'tuesday', starting_time: Time.zone.parse('2012-05-05 16:00:00'),
                                   duration: 60, capacity: 3, appointment_type: @appointment_type, agenda: @agenda
    visit places_path
    click_link 'Modifier'
    click_link 'Créneaux récurrents'
    expect(page).to have_content 'Créneaux récurrents'
    expect(page).to have_content 'test_place_name : test_agenda_name'
    expect(page).to have_content 'apt_type_name'
    expect(page).to have_css "#edit_slot_type_#{slot_type1.id}"
    expect(page).to have_css "#edit_slot_type_#{slot_type2.id}"
  end

  scenario 'An admin edits a slot type' do
    create_admin_user_and_login
    slot_type = create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
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

  scenario 'An admin creates a slot type' do
    create_admin_user_and_login
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

  scenario 'An admin delete a slot type' do
    create_admin_user_and_login
    slot_type = create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
                                   duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda
    visit agenda_slot_types_path(@agenda)
    within "#edit_slot_type_#{slot_type.id}"
    expect { click_link 'Supprimer' }.to change(SlotType, :count).from(1).to(0)
  end
end
