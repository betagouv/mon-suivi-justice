require 'rails_helper'

RSpec.feature 'SlotTypes', type: :feature do
  before do
    @place = create :place, name:'test_place_name'
    @agenda = create :agenda, place: @place, name: 'test_agenda_name'
    @appointment_type = create :appointment_type, name: 'apt_type_name'
  end

  scenario 'An admin consults slot types' do
    create_admin_user_and_login
    create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
                       duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda
    create :slot_type, week_day: 'tuesday', starting_time: Time.zone.parse('2012-05-05 16:00:00'),
                       duration: 60, capacity: 3, appointment_type: @appointment_type, agenda: @agenda
    visit places_path
    click_link 'Modifier'
    click_link 'Gérer les créneaux'
    expect(page).to have_content "Gestion des créneaux test_place_name : test_agenda_name"
  end

  scenario 'An admin edits a slot type' do
    create_admin_user_and_login
    slot_type = create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
                       duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda
    visit agenda_slot_types_path(@agenda)
    within "#edit_slot_type_#{slot_type.id}" do
      select 'Jeudi', from: :slot_type_week_day
      fill_in :slot_type_duration, with: 23
      fill_in :slot_type_capacity, with: 6
      click_button 'Enregistrer'
    end
    expect(SlotType.find_by(id: slot_type.id, week_day: 'thursday', duration: 23, capacity: 6)).not_to be_nil
  end

  scenario 'An admin creates a slot type' do
    create_admin_user_and_login
    visit agenda_slot_types_path(@agenda)
    within "#new_slot_type" do
      select 'apt_type_name', from: :slot_type_appointment_type_id
      select 'Mardi', from: :slot_type_week_day
      fill_in :slot_type_duration, with: 23
      fill_in :slot_type_capacity, with: 6
      click_button 'Enregistrer'
    end
    expect(SlotType.find_by(week_day: 'mardi', duration: 23, capacity: 6)).not_to be_nil
  end


  scenario 'An admin delete a slot type' do
    create_admin_user_and_login
    create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
                       duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda
    visit slot_types_path
    expect(page).to have_content "#{@appointment_type.name} #{@agenda.name} Lundi 10:00 30 1"
    expect { click_link 'Supprimer' }.to change(SlotType, :count).from(1).to(0)
    expect(page).not_to have_content "#{@appointment_type.name} #{@agenda.name} Jeudi 15:25 23 6"
  end
end
